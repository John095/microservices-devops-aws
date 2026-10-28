variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "ecr_repository_url" {
  description = "ECR repository URL"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 2
}

variable "db_host" {
  description = "Database hostname"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the RDS-managed secret holding the database credentials"
  type        = string
}

variable "jwt_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the JWT signing key"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "api_target_group_arn" {
  description = "API service target group ARN"
  type        = string
}

variable "auth_target_group_arn" {
  description = "Auth service target group ARN"
  type        = string
}

variable "frontend_target_group_arn" {
  description = "Frontend target group ARN"
  type        = string
}

variable "alb_listener" {
  description = "ALB listener dependency"
  type        = any
}