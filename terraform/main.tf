terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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

  name               = var.name
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.vpc.rds_security_group_id]
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  instance_class     = var.db_instance_class
  multi_az           = var.environment == "prod" ? true : false
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

# ECS Module
module "ecs" {
  source = "./modules/ecs"

  cluster_name               = "${var.name}-cluster"
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnet_ids
  security_group_id          = module.vpc.ecs_security_group_id
  ecr_repository_url         = data.aws_caller_identity.current.account_id
  image_tag                  = var.image_tag
  desired_count              = var.desired_count
  database_url               = "postgresql://${var.db_username}:${var.db_password}@${module.rds.db_instance_endpoint}/${var.db_name}"
  jwt_secret                 = var.jwt_secret
  aws_region                 = var.aws_region
  api_target_group_arn       = module.alb.api_target_group_arn
  auth_target_group_arn      = module.alb.auth_target_group_arn
  frontend_target_group_arn  = module.alb.frontend_target_group_arn
  alb_listener               = module.alb.http_listener_arn
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
