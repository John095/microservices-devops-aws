name                = "microservices-devops-prod"
environment         = "prod"
aws_region         = "us-east-1"
vpc_cidr           = "10.0.0.0/16"

# Database configuration
db_name            = "appdb"
db_username        = "dbadmin"
db_password        = "prod-db-password-123!"
db_instance_class  = "db.t3.small"

# ECS configuration
desired_count      = 3
image_tag          = "latest"

# Security
jwt_secret         = "CHANGE-THIS-SUPER-SECRET-JWT-KEY-IN-PRODUCTION"

# SSL Certificate (required for prod)
certificate_arn    = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"