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

variable "database_url" {
  description = "Database connection URL"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  sensitive   = true
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