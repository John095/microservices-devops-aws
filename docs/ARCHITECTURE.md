# Architecture

## Components

- **VPC**: Isolated network with public/private subnets
- **ECS Fargate**: Serverless containers
- **RDS**: Managed PostgreSQL
- **ALB**: Distributes traffic
- **ECR**: Private Docker registry
- **GitHub Actions**: CI/CD

## Deployment Strategy

Blue-green via ECS service updates.