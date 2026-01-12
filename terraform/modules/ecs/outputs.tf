output "cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "api_service_name" {
  description = "API service name"
  value       = aws_ecs_service.api.name
}

output "auth_service_name" {
  description = "Auth service name"
  value       = aws_ecs_service.auth.name
}

output "frontend_service_name" {
  description = "Frontend service name"
  value       = aws_ecs_service.frontend.name
}