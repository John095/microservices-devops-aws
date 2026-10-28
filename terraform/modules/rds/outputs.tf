output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.main.arn
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}
output "db_instance_address" {
  description = "RDS hostname (endpoint without the port)"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "RDS port"
  value       = aws_db_instance.main.port
}

output "master_user_secret_arn" {
  description = "ARN of the RDS-managed Secrets Manager secret holding the master credentials"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}
