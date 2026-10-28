terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = var.vpc_cidr
  name     = var.name
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  name                = var.name
  subnet_ids          = module.vpc.private_subnet_ids
  security_group_ids  = [module.vpc.rds_security_group_id]
  db_name             = var.db_name
  db_username         = var.db_username
  instance_class      = var.db_instance_class
  multi_az            = var.environment == "prod" ? true : false
  deletion_protection = var.environment == "prod" ? true : false
}

# ALB Module
module "alb" {
  source = "./modules/alb"

  name              = var.name
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.vpc.alb_security_group_id
  certificate_arn   = var.certificate_arn
}

# ECR Repositories
resource "aws_ecr_repository" "api" {
  name                 = "${var.name}/api-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.name}-api-ecr"
  }
}

resource "aws_ecr_repository" "auth" {
  name                 = "${var.name}/auth-service"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.name}-auth-ecr"
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "${var.name}/frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.name}-frontend-ecr"
  }
}

# JWT signing key — generated, never typed or committed. Note: random_password's
# result is stored in Terraform state, so the state backend must be private and encrypted.
resource "random_password" "jwt" {
  length  = 64
  special = false
}

resource "aws_secretsmanager_secret" "jwt" {
  name_prefix = "${var.name}-jwt-"
  description = "JWT signing key for auth-service"
}

resource "aws_secretsmanager_secret_version" "jwt" {
  secret_id     = aws_secretsmanager_secret.jwt.id
  secret_string = random_password.jwt.result
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"

  cluster_name              = "${var.name}-cluster"
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.private_subnet_ids
  security_group_id         = module.vpc.ecs_security_group_id
  ecr_repository_url        = data.aws_caller_identity.current.account_id
  image_tag                 = var.image_tag
  desired_count             = var.desired_count
  db_host                   = module.rds.db_instance_address
  db_port                   = module.rds.db_instance_port
  db_name                   = var.db_name
  db_username               = var.db_username
  db_secret_arn             = module.rds.master_user_secret_arn
  jwt_secret_arn            = aws_secretsmanager_secret.jwt.arn
  aws_region                = var.aws_region
  api_target_group_arn      = module.alb.api_target_group_arn
  auth_target_group_arn     = module.alb.auth_target_group_arn
  frontend_target_group_arn = module.alb.frontend_target_group_arn
  alb_listener              = module.alb.http_listener_arn
}

# S3 Bucket for static assets
resource "aws_s3_bucket" "assets" {
  bucket = "${var.name}-assets-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "${var.name}-assets"
  }
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}
