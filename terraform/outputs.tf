output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.alb.alb_dns_name
}

output "database_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_id
}

output "ecr_repositories" {
  description = "ECR repository URLs"
  value = {
    api      = aws_ecr_repository.api.repository_url
    auth     = aws_ecr_repository.auth.repository_url
    frontend = aws_ecr_repository.frontend.repository_url
  }
}

output "s3_bucket_name" {
  description = "S3 bucket name for assets"
  value       = aws_s3_bucket.assets.bucket
}