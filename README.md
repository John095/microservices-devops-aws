# Microservices DevOps Infrastructure on AWS

A complete DevOps infrastructure implementation featuring microservices architecture, containerization with Docker, Infrastructure as Code with Terraform, and automated CI/CD pipelines with GitHub Actions.

## 🏗️ Architecture Overview

This project demonstrates enterprise-grade DevOps practices with:

- **Microservices Architecture**: 3 containerized services (API, Auth, Frontend)
- **AWS Cloud Infrastructure**: VPC, ECS, RDS, ALB, S3, CloudWatch
- **Infrastructure as Code**: Terraform modules for reproducible infrastructure
- **CI/CD Pipeline**: Automated testing, building, and deployment with GitHub Actions
- **Container Orchestration**: Docker and AWS ECS with auto-scaling
- **High Availability**: Multi-AZ deployment with load balancing

## 🚀 Features

- ✅ Multi-tier VPC with public and private subnets
- ✅ Auto-scaling ECS cluster with Fargate
- ✅ RDS PostgreSQL with automated backups
- ✅ Application Load Balancer with health checks
- ✅ Blue-green deployment strategy
- ✅ CloudWatch monitoring and alerting
- ✅ Secrets management with AWS Secrets Manager
- ✅ S3 for static assets and backups
- ✅ Security groups and IAM policies
- ✅ Automated CI/CD with GitHub Actions

## 📋 Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0
- Docker >= 20.10
- AWS CLI configured
- Node.js >= 18 (for services)
- GitHub account (for CI/CD)

## 🛠️ Tech Stack

- **Cloud Provider**: AWS
- **IaC Tool**: Terraform
- **Container Runtime**: Docker
- **Orchestration**: AWS ECS (Fargate)
- **CI/CD**: GitHub Actions
- **Database**: PostgreSQL (RDS)
- **Load Balancer**: Application Load Balancer
- **Monitoring**: CloudWatch
- **Languages**: Node.js, Bash

## 📁 Project Structure

```
microservices-devops-aws/
├── terraform/          # Infrastructure as Code
├── services/          # Microservices source code
├── .github/workflows/ # CI/CD pipelines
├── scripts/           # Automation scripts
└── docs/             # Documentation
```

## 🚦 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/microservices-devops-aws.git
cd microservices-devops-aws
```

### 2. Configure AWS Credentials

```bash
aws configure
```

### 3. Set Up Terraform Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 4. Initialize and Apply Terraform

```bash
terraform init
terraform plan
terraform apply
```

### 5. Build and Push Docker Images

```bash
# Build all services
docker-compose build

# Tag and push to ECR (replace with your ECR URLs)
./scripts/push-images.sh
```

### 6. Deploy Services

```bash
./scripts/deploy.sh
```

## 🔄 CI/CD Pipeline

The GitHub Actions pipeline automatically:

1. **Lint & Test**: Runs code quality checks and unit tests
2. **Build**: Creates Docker images for all services
3. **Security Scan**: Scans for vulnerabilities with Trivy
4. **Push to ECR**: Uploads images to AWS ECR
5. **Deploy to ECS**: Updates ECS services with new images
6. **Health Check**: Verifies deployment success

### Triggering Deployments

- **Push to `main`**: Deploys to production
- **Push to `develop`**: Deploys to staging
- **Pull Request**: Runs tests and builds only

## 🏗️ Infrastructure Components

### VPC Configuration
- CIDR: 10.0.0.0/16
- Public Subnets: 2 AZs
- Private Subnets: 2 AZs
- NAT Gateway for private subnet internet access

### ECS Cluster
- Fargate launch type
- Auto-scaling (2-10 tasks)
- Blue-green deployment
- Health checks and rollback

### RDS Database
- PostgreSQL 14
- Multi-AZ deployment
- Automated backups (7 days retention)
- Encrypted at rest

### Load Balancer
- Application Load Balancer
- HTTPS with ACM certificate
- Health checks on /health endpoint
- Sticky sessions enabled

## 📊 Monitoring & Logging

- **CloudWatch Logs**: Centralized logging for all services
- **CloudWatch Metrics**: Custom metrics for application monitoring
- **CloudWatch Alarms**: Alerts for critical events
- **X-Ray**: Distributed tracing (optional)

## 🔒 Security Best Practices

- ✅ Private subnets for application and database layers
- ✅ Security groups with least privilege
- ✅ IAM roles with minimal permissions
- ✅ Secrets stored in AWS Secrets Manager
- ✅ Encrypted RDS with KMS
- ✅ VPC Flow Logs enabled
- ✅ Container vulnerability scanning

## 🧪 Testing

```bash
# Run unit tests
npm test

# Run integration tests
npm run test:integration

# Test Docker builds locally
docker-compose up
```

## 📝 Environment Variables

Required environment variables for services:

```env
DATABASE_URL=postgresql://user:pass@host:5432/db
JWT_SECRET=your-secret-key
AWS_REGION=us-east-1
NODE_ENV=production
```

## 💰 Cost Estimation

Approximate monthly AWS costs:

- ECS Fargate: $30-50
- RDS (db.t3.small): $30-40
- ALB: $20-25
- NAT Gateway: $30-35
- Data Transfer: $10-20
- **Total**: ~$120-170/month

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

MIT License - see LICENSE file for details

## 📞 Support

For issues and questions:
- Open an issue on GitHub
- Email: your-email@example.com

## 🔗 Useful Links

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## ⭐ Show Your Support

Give a ⭐️ if this project helped you!