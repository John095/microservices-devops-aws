name                = "microservices-devops-dev"
environment         = "dev"
aws_region         = "us-east-1"
vpc_cidr           = "10.0.0.0/16"

# Database configuration
db_name            = "appdb"
db_username        = "dbadmin"
db_password        = "admin123!"
db_instance_class  = "db.t3.micro"

# ECS configuration
desired_count      = 1
image_tag          = "latest"

# Security
jwt_secret         = "dev-jwt-secret-key-change-in-production"

# SSL Certificate (optional for dev)
certificate_arn    = ""