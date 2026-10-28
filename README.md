# Microservices DevOps Infrastructure on AWS

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-1.0+-purple.svg)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-orange.svg)](https://aws.amazon.com/)
[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)

A production-ready microservices infrastructure on AWS, demonstrating enterprise-grade DevOps practices with Infrastructure as Code (Terraform), containerization (Docker), orchestration (ECS), and automated CI/CD pipelines (GitHub Actions).

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Infrastructure Components](#infrastructure-components)
- [CI/CD Pipeline](#cicd-pipeline)
- [Deployment](#deployment)
- [Monitoring & Logging](#monitoring--logging)
- [Security](#security)
- [Cost Optimization](#cost-optimization)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## 🎯 Overview

This project provides a complete, real-world example of deploying a microservices-based application on AWS using modern DevOps practices. It's designed to be a learning resource and a production-ready template for teams looking to implement similar architectures.

### What This Project Demonstrates

- **Microservices Architecture**: Loosely coupled services with independent deployment cycles
- **Infrastructure as Code**: Fully automated, version-controlled infrastructure with Terraform
- **Containerization**: Docker-based microservices for consistency across environments
- **Cloud-Native**: AWS-managed services for scalability, reliability, and reduced operational overhead
- **CI/CD Automation**: End-to-end automated pipelines from code commit to production deployment
- **Production Best Practices**: Security, monitoring, high availability, and disaster recovery

---

## 🏗️ Architecture

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                          Internet Gateway                        │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                ┌───────────▼──────────┐
                │  Application Load    │
                │      Balancer        │
                └───────────┬──────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼────────┐  ┌──────▼──────┐  ┌────────▼────────┐
│   Frontend     │  │  API Service │  │  Auth Service   │
│   Service      │  │              │  │                 │
│   (ECS)        │  │   (ECS)      │  │    (ECS)        │
└────────────────┘  └──────┬───────┘  └────────┬────────┘
                           │                   │
                    ┌──────▼───────────────────▼──────┐
                    │     RDS PostgreSQL (Multi-AZ)   │
                    │     Private Subnet              │
                    └─────────────────────────────────┘
```

### Network Architecture

- **VPC**: Isolated network with CIDR 10.0.0.0/16
- **Public Subnets** (2 AZs): Host ALB and NAT Gateways
- **Private Subnets** (2 AZs): Host ECS tasks and RDS instances
- **Multi-AZ Deployment**: High availability across availability zones
- **NAT Gateways**: Secure outbound internet access for private resources

### Service Architecture

#### 1. **Frontend Service**

- React/Vue.js single-page application
- Serves static assets and client-side routing
- Communicates with API service via ALB

#### 2. **API Service**

- RESTful API for business logic
- Handles CRUD operations
- Communicates with database and auth service

#### 3. **Auth Service**

- JWT-based authentication
- User management and session handling
- Centralized authentication for all services

---

## ✨ Features

### Infrastructure

- ✅ **Multi-tier VPC** with public/private subnets across 2 availability zones
- ✅ **Auto-scaling ECS cluster** with Fargate (serverless containers)
- ✅ **RDS PostgreSQL** with automated backups and Multi-AZ failover
- ✅ **Application Load Balancer** with health checks and SSL termination
- ✅ **S3 buckets** for static assets, logs, and Terraform state
- ✅ **CloudWatch** for comprehensive monitoring and alerting
- ✅ **Secrets Manager** for secure credential management

### DevOps & Automation

- ✅ **Terraform modules** for reusable, maintainable infrastructure
- ✅ **GitHub Actions workflows** for automated CI/CD
- ✅ **Blue-green deployments** for zero-downtime updates
- ✅ **Automated rollback** on deployment failures
- ✅ **Docker multi-stage builds** for optimized images
- ✅ **Container vulnerability scanning** with Trivy

### Security & Compliance

- ✅ **Private subnets** for application and database layers
- ✅ **Security groups** with principle of least privilege
- ✅ **IAM roles** with minimal required permissions
- ✅ **Encrypted RDS** with AWS KMS
- ✅ **VPC Flow Logs** for network traffic analysis
- ✅ **Secrets rotation** policies

---

## 🛠️ Tech Stack

| Category                   | Technologies                                              |
| -------------------------- | --------------------------------------------------------- |
| **Cloud Provider**         | AWS (VPC, ECS, RDS, ALB, S3, CloudWatch, Secrets Manager) |
| **Infrastructure as Code** | Terraform 1.0+                                            |
| **Container Platform**     | Docker, AWS ECS (Fargate)                                 |
| **CI/CD**                  | GitHub Actions                                            |
| **Database**               | PostgreSQL 14 (AWS RDS)                                   |
| **Load Balancing**         | Application Load Balancer (ALB)                           |
| **Monitoring**             | CloudWatch Logs, Metrics, Alarms                          |
| **Programming Languages**  | Node.js/TypeScript, JavaScript, Shell                     |
| **Version Control**        | Git, GitHub                                               |

---

## 📁 Project Structure

```
microservices-devops-aws/
├── .github/
│   └── workflows/              # CI/CD pipeline definitions
│       ├── deploy-production.yml
│       ├── deploy-staging.yml
│       └── test.yml
├── terraform/
│   ├── modules/               # Reusable Terraform modules
│   │   ├── vpc/              # VPC and networking
│   │   ├── ecs/              # ECS cluster and services
│   │   ├── rds/              # RDS database
│   │   ├── alb/              # Application Load Balancer
│   │   └── monitoring/       # CloudWatch setup
│   ├── environments/         # Environment-specific configs
│   │   ├── production/
│   │   └── staging/
│   ├── main.tf               # Root module
│   ├── variables.tf          # Input variables
│   ├── outputs.tf            # Output values
│   └── terraform.tfvars.example
├── services/
│   ├── frontend/             # Frontend microservice
│   │   ├── src/
│   │   ├── Dockerfile
│   │   └── package.json
│   ├── api/                  # API microservice
│   │   ├── src/
│   │   ├── Dockerfile
│   │   └── package.json
│   └── auth/                 # Authentication microservice
│       ├── src/
│       ├── Dockerfile
│       └── package.json
├── scripts/
│   ├── deploy.sh            # Deployment automation
│   ├── push-images.sh       # ECR image push
│   ├── setup.sh             # Initial setup
│   └── teardown.sh          # Cleanup script
├── docs/
│   ├── architecture.md      # Architecture details
│   ├── deployment.md        # Deployment guide
│   └── troubleshooting.md   # Common issues
├── docker-compose.yml       # Local development setup
├── .gitignore
├── package.json
└── README.md
```

---

## 📦 Prerequisites

Before you begin, ensure you have the following installed and configured:

### Required Tools

- **AWS Account** with administrative access
- **AWS CLI** (v2.x) - [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- **Terraform** (≥ 1.0) - [Download](https://www.terraform.io/downloads)
- **Docker** (≥ 20.10) - [Get Docker](https://docs.docker.com/get-docker/)
- **Docker Compose** (≥ 2.0)
- **Node.js** (≥ 18) - [Download](https://nodejs.org/)
- **Git** (≥ 2.30)

### AWS Configuration

```bash
# Configure AWS credentials
aws configure

# Verify configuration
aws sts get-caller-identity
```

### GitHub Setup

- GitHub account with repository access
- GitHub Actions enabled
- Repository secrets configured (see CI/CD section)

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/John095/microservices-devops-aws.git
cd microservices-devops-aws
```

### 2. Install Dependencies

```bash
# Install npm dependencies
npm install

# Install service dependencies
cd services/api && npm install
cd ../auth && npm install
cd ../frontend && npm install
cd ../..
```

### 3. Set Up Terraform Backend

Create an S3 bucket for Terraform state:

```bash
# Create S3 bucket
aws s3 mb s3://your-terraform-state-bucket --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket your-terraform-state-bucket \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket your-terraform-state-bucket \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

### 4. Configure Terraform Variables

```bash
cd terraform

# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

**terraform.tfvars** example:

```hcl
aws_region          = "us-east-1"
project_name        = "microservices-app"
environment         = "production"
vpc_cidr            = "10.0.0.0/16"

# ECS Configuration
ecs_cluster_name    = "microservices-cluster"
desired_count       = 2
cpu                 = 256
memory              = 512

# RDS Configuration
db_instance_class   = "db.t3.small"
db_name             = "appdb"
db_username         = "admin"

# Domain (optional)
domain_name         = "example.com"
```

### 5. Initialize and Apply Terraform

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan infrastructure changes
terraform plan

# Apply changes (creates infrastructure)
terraform apply
```

**Expected output:**

```
Apply complete! Resources: 47 added, 0 changed, 0 destroyed.

Outputs:
alb_dns_name = "microservices-alb-123456789.us-east-1.elb.amazonaws.com"
ecr_repositories = {
  "api" = "123456789.dkr.ecr.us-east-1.amazonaws.com/microservices-api"
  "auth" = "123456789.dkr.ecr.us-east-1.amazonaws.com/microservices-auth"
  "frontend" = "123456789.dkr.ecr.us-east-1.amazonaws.com/microservices-frontend"
}
rds_endpoint = "microservices-db.xxxxx.us-east-1.rds.amazonaws.com:5432"
```

### 6. Build and Push Docker Images

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Build and push all services
./scripts/push-images.sh
```

### 7. Initial Deployment

```bash
# Deploy all services
./scripts/deploy.sh

# Or deploy individually
./scripts/deploy.sh frontend
./scripts/deploy.sh api
./scripts/deploy.sh auth
```

### 8. Verify Deployment

```bash
# Get ALB DNS name
terraform output alb_dns_name

# Check health endpoint
curl http://<alb-dns-name>/health

# View ECS services
aws ecs list-services --cluster microservices-cluster

# Check logs
aws logs tail /ecs/microservices/api --follow
```

---

## 🏛️ Infrastructure Components

### VPC & Networking

**Configuration:**

- **CIDR Block**: 10.0.0.0/16 (65,536 IP addresses)
- **Public Subnets**: 10.0.1.0/24, 10.0.2.0/24 (across 2 AZs)
- **Private Subnets**: 10.0.10.0/24, 10.0.11.0/24 (across 2 AZs)
- **Internet Gateway**: For public subnet internet access
- **NAT Gateways**: 2 (one per AZ) for private subnet outbound access
- **Route Tables**: Separate for public and private subnets

**Key Features:**

- Multi-AZ deployment for high availability
- Network ACLs for additional security layer
- VPC Flow Logs enabled for traffic monitoring

### ECS Cluster (Fargate)

**Configuration:**

- **Launch Type**: Fargate (serverless)
- **Task CPU**: 256 (.25 vCPU)
- **Task Memory**: 512 MB
- **Desired Count**: 2 tasks per service
- **Auto-scaling**: 2-10 tasks based on CPU/memory utilization

**Services:**

1. **Frontend Service**

   - Port: 3000
   - Health check: `/health`
   - Auto-scaling target: 70% CPU

2. **API Service**

   - Port: 5000
   - Health check: `/api/health`
   - Auto-scaling target: 70% CPU

3. **Auth Service**
   - Port: 4000
   - Health check: `/auth/health`
   - Auto-scaling target: 70% CPU

**Deployment Configuration:**

- **Strategy**: Rolling update
- **Maximum Percent**: 200%
- **Minimum Healthy Percent**: 100%
- **Circuit Breaker**: Enabled with automatic rollback

### RDS PostgreSQL

**Configuration:**

- **Engine**: PostgreSQL 14.x
- **Instance Class**: db.t3.small (production), db.t3.micro (staging)
- **Storage**: 20 GB GP2 SSD (auto-scaling enabled)
- **Multi-AZ**: Enabled for production
- **Backup Retention**: 7 days
- **Encryption**: AES-256 with AWS KMS
- **Parameter Group**: Custom with optimized settings

**High Availability:**

- Automatic failover to standby instance
- Automated backups with point-in-time recovery
- Read replicas (optional, configured separately)

**Security:**

- Deployed in private subnets
- Security group allows access only from ECS tasks
- SSL/TLS enforced for connections

### Application Load Balancer

**Configuration:**

- **Type**: Application Load Balancer
- **Scheme**: Internet-facing
- **Availability Zones**: 2
- **Listeners**:
  - HTTP (80) → Redirect to HTTPS
  - HTTPS (443) → Forward to target groups

**Target Groups:**

- **Frontend**: Path `/` → Frontend service
- **API**: Path `/api/*` → API service
- **Auth**: Path `/auth/*` → Auth service

**Health Checks:**

- **Interval**: 30 seconds
- **Timeout**: 5 seconds
- **Healthy threshold**: 2
- **Unhealthy threshold**: 3

**Features:**

- Sticky sessions (cookie-based)
- Connection draining (300 seconds)
- Access logs stored in S3
- WAF integration (optional)

### CloudWatch Monitoring

**Log Groups:**

- `/ecs/microservices/frontend`
- `/ecs/microservices/api`
- `/ecs/microservices/auth`
- `/aws/rds/microservices-db`

**Metrics:**

- ECS service CPU/memory utilization
- ALB request count, latency, HTTP responses
- RDS CPU, storage, connections
- Custom application metrics

**Alarms:**

- High CPU utilization (>80% for 5 minutes)
- High memory utilization (>80% for 5 minutes)
- ALB 5xx errors (>10 in 5 minutes)
- RDS storage space (<20% free)
- Failed ECS task launches

### Secrets Manager

No secret is typed, committed, or written into a task definition:

| Secret | Created by | Reaches the container as |
|---|---|---|
| RDS master password | RDS itself (`manage_master_user_password = true`) | `PGPASSWORD`, via the task definition's `secrets` (`<arn>:password::`) |
| JWT signing key | Terraform (`random_password` → `aws_secretsmanager_secret`) | `JWT_SECRET`, via `secrets` |

- The ECS **execution role** has `secretsmanager:GetSecretValue` on exactly those two ARNs; ECS resolves them before the container starts.
- Non-secret connection details (`PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`) are plain environment variables; `node-postgres` reads them natively.
- `auth-service` refuses to start in production without `JWT_SECRET` instead of falling back to a default key.

**Rotation caveat:** RDS rotates the managed password every 7 days by default, but ECS injects `secrets` only at task start. Running tasks keep the old password, and new connections fail after a rotation until the tasks restart. Options: trigger `aws ecs update-service --force-new-deployment` from an EventBridge rule on the rotation event, or have the app fetch the secret itself and retry on authentication failure.

**State caveat:** the RDS password never touches Terraform state, but the JWT key from `random_password` does, so the state backend must be private and encrypted.

---

## 🔄 CI/CD Pipeline

### Pipeline Architecture

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   Git Push   │───▶│  Run Tests   │───▶│ Build Images │───▶│Deploy to ECS │
│  to main     │    │   & Lint     │    │ & Push to    │    │   & Verify   │
└──────────────┘    └──────────────┘    │     ECR      │    └──────────────┘
                                        └──────────────┘
```

### GitHub Actions Workflows

#### 1. **Test Workflow** (`.github/workflows/test.yml`)

Triggers on: Pull requests, pushes to `develop`

Steps:

1. Checkout code
2. Setup Node.js environment
3. Install dependencies
4. Run linting (ESLint)
5. Run unit tests (Jest)
6. Run integration tests
7. Generate test coverage report
8. Upload coverage to Codecov

#### 2. **Build & Deploy Workflow** (`.github/workflows/deploy-production.yml`)

Triggers on: Pushes to `main` branch

Steps:

1. **Checkout code**
2. **Configure AWS credentials**
3. **Login to Amazon ECR**
4. **Build Docker images**
   - Multi-stage builds for optimization
   - Tagging with commit SHA and `latest`
5. **Security scan** (Trivy)
   - Scan for vulnerabilities
   - Fail on high/critical CVEs
6. **Push images to ECR**
7. **Update ECS task definitions**
   - Download current task definition
   - Update image tags
   - Register new task definition
8. **Deploy to ECS**
   - Update service with new task definition
   - Wait for service stability
   - Monitor deployment status
9. **Health check**
   - Verify endpoints are responding
   - Check CloudWatch metrics
10. **Rollback** (if failure detected)
    - Revert to previous task definition
    - Notify team via Slack/email

### GitHub Secrets Configuration

Required secrets in repository settings:

```
AWS_ACCESS_KEY_ID         # AWS access key for deployments
AWS_SECRET_ACCESS_KEY     # AWS secret key
AWS_REGION                # AWS region (e.g., us-east-1)
SLACK_WEBHOOK_URL         # For deployment notifications (optional)
```

### Deployment Strategies

**Blue-Green Deployment:**

```yaml
# In ECS task definition
deployment_configuration {
deployment_circuit_breaker {
enable   = true
rollback = true
}
maximum_percent         = 200
minimum_healthy_percent = 100
}
```

**Canary Deployment** (optional):

- Route 10% of traffic to new version
- Monitor metrics for 10 minutes
- Gradually increase to 100% or rollback

---

## 📊 Monitoring & Logging

### CloudWatch Dashboards

**Custom Dashboard** (`microservices-overview`):

- ECS service health (running tasks, CPU, memory)
- ALB metrics (requests, latency, errors)
- RDS metrics (connections, CPU, storage)
- Application-specific metrics

### Log Aggregation

**Centralized Logging:**

```bash
# View logs from all services
aws logs tail /ecs/microservices --since 1h --follow

# Filter by service
aws logs tail /ecs/microservices/api --filter-pattern "ERROR" --follow

# Export logs to S3 for long-term storage
aws logs create-export-task \
  --log-group-name /ecs/microservices/api \
  --from $(date -d '7 days ago' +%s)000 \
  --to $(date +%s)000 \
  --destination s3://your-logs-bucket
```

### Alerting Configuration

**Critical Alarms:**

1. **Service Down**: No healthy tasks running → PagerDuty
2. **High Error Rate**: 5xx errors > 5% → Slack + Email
3. **Database Issues**: Connection failures → PagerDuty
4. **Cost Anomaly**: Unexpected spending increase → Email

**Warning Alarms:**

1. **High CPU**: > 70% for 10 minutes → Slack
2. **High Memory**: > 70% for 10 minutes → Slack
3. **Slow Response**: P95 latency > 500ms → Email

### Performance Monitoring

**Application Performance Monitoring (APM):**

- AWS X-Ray for distributed tracing
- Custom metrics for business KPIs
- Real User Monitoring (RUM) for frontend

---

## 🔒 Security

### Network Security

**Security Group Rules:**

```
ALB Security Group:
  Inbound:  Allow 80, 443 from 0.0.0.0/0
  Outbound: Allow all to ECS security group

ECS Security Group:
  Inbound:  Allow 3000, 4000, 5000 from ALB security group
  Outbound: Allow 443 to 0.0.0.0/0 (for AWS API calls)
            Allow 5432 to RDS security group

RDS Security Group:
  Inbound:  Allow 5432 from ECS security group
  Outbound: None
```

### IAM Policies

**ECS Task Execution Role:**

- Pull images from ECR
- Write logs to CloudWatch
- Read secrets from Secrets Manager

**ECS Task Role:**

- Application-specific permissions
- Minimal required access to AWS services
- No root/admin permissions

### Data Encryption

- **In Transit**: TLS 1.2+ for all connections
- **At Rest**:
  - RDS: AES-256 with KMS
  - S3: SSE-S3 or SSE-KMS
  - EBS: Encrypted volumes

### Compliance

- VPC Flow Logs for audit trail
- CloudTrail for API activity logging
- Config Rules for compliance monitoring
- Regular security scanning with AWS Inspector

---

## 💰 Cost Optimization

### Estimated Monthly Costs (Production)

| Service                   | Configuration                  | Est. Cost           |
| ------------------------- | ------------------------------ | ------------------- |
| ECS Fargate               | 6 tasks × 0.25 vCPU, 0.5GB RAM | $25-35              |
| RDS PostgreSQL            | db.t3.small, Multi-AZ          | $60-70              |
| Application Load Balancer | 1 ALB                          | $22-25              |
| NAT Gateway               | 2 gateways                     | $65-75              |
| Data Transfer             | ~100 GB/month                  | $9-12               |
| CloudWatch                | Logs + Metrics                 | $5-10               |
| S3                        | State, logs, backups           | $3-5                |
| **Total**                 |                                | **~$190-230/month** |

### Cost Reduction Strategies

1. **Use Fargate Spot** (staging): Save up to 70%

   ```hcl
   capacity_provider_strategy {
     capacity_provider = "FARGATE_SPOT"
     weight            = 100
   }
   ```

2. **Right-size Resources**: Monitor actual usage and adjust

   ```bash
   # Check ECS task utilization
   aws cloudwatch get-metric-statistics \
     --namespace AWS/ECS \
     --metric-name CPUUtilization \
     --dimensions Name=ServiceName,Value=api-service \
     --start-time $(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%S) \
     --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
     --period 3600 \
     --statistics Average
   ```

3. **Use Reserved Instances** for predictable RDS workloads (up to 40% savings)

4. **Implement Auto-scaling**: Scale down during off-peak hours

5. **Optimize NAT Gateway**: Use VPC Endpoints for AWS services

6. **Log Retention**: Reduce CloudWatch log retention to 7-14 days

7. **Clean up unused resources**:

   ```bash
   # Find unused EBS volumes
   aws ec2 describe-volumes --filters Name=status,Values=available

   # Find old ECR images
   aws ecr describe-images --repository-name api --query 'sort_by(imageDetails, &imagePushedAt)[:-5]'
   ```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. ECS Tasks Failing to Start

**Symptoms**: Tasks continuously stop and restart

**Solutions**:

```bash
# Check task stopped reason
aws ecs describe-tasks --cluster microservices-cluster --tasks <task-id>

# Common causes:
# - Insufficient memory: Increase memory in task definition
# - Image pull errors: Verify ECR permissions
# - Health check failures: Review application logs
# - Port conflicts: Check port mappings
```

#### 2. Database Connection Errors

**Symptoms**: Services can't connect to RDS

**Solutions**:

```bash
# Verify security group rules
aws ec2 describe-security-groups --group-ids <rds-sg-id>

# Test connectivity from ECS task
aws ecs execute-command \
  --cluster microservices-cluster \
  --task <task-id> \
  --container api \
  --command "/bin/sh" \
  --interactive

# Inside container:
nc -zv <rds-endpoint> 5432
```

#### 3. High Latency

**Symptoms**: Slow API responses

**Solutions**:

```bash
# Check ALB target health
aws elbv2 describe-target-health --target-group-arn <tg-arn>

# Review CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name TargetResponseTime \
  --dimensions Name=LoadBalancer,Value=app/microservices-alb/xxx \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average,Maximum

# Optimize:
# - Add database indexes
# - Implement caching (Redis/ElastiCache)
# - Scale ECS tasks
# - Use read replicas for RDS
```

#### 4. Deployment Failures

**Symptoms**: GitHub Actions deployment fails

**Solutions**:

```bash
# Check GitHub Actions logs
# Verify AWS credentials
aws sts get-caller-identity

# Test ECS deployment locally
aws ecs update-service \
  --cluster microservices-cluster \
  --service api-service \
  --force-new-deployment

# Rollback if needed
aws ecs update-service \
  --cluster microservices-cluster \
  --service api-service \
  --task-definition api:123  # previous revision
```

### Debugging Commands

```bash
# View ECS service events
aws ecs describe-services \
  --cluster microservices-cluster \
  --services api-service \
  --query 'services[0].events[:5]'

# Check CloudWatch logs
aws logs tail /ecs/microservices/api --since 30m --follow

# Describe task definition
aws ecs describe-task-definition --task-definition api

# List running tasks
aws ecs list-tasks --cluster microservices-cluster --service-name api-service

# Get task details
aws ecs describe-tasks --cluster microservices-cluster --tasks <task-id>

# Check ALB health
aws elbv2 describe-target-health --target-group-arn <tg-arn>
```

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### How to Contribute

1. **Fork the repository**

   ```bash
   gh repo fork John095/microservices-devops-aws
   ```

2. **Create a feature branch**

   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make your changes**

   - Follow existing code style
   - Add tests for new features
   - Update documentation

4. **Run tests**

   ```bash
   npm test
   terraform fmt -check
   terraform validate
   ```

5. **Commit your changes**

   ```bash
   git commit -m "feat: add amazing feature"
   ```

   Use [Conventional Commits](https://www.conventionalcommits.org/)

6. **Push to your fork**

   ```bash
   git push origin feature/amazing-feature
   ```

7. **Open a Pull Request**
   - Describe your changes
   - Reference any related issues
   - Wait for review

### Development Setup

```bash
# Install pre-commit hooks
npm install husky --save-dev
npx husky install

# Run locally with Docker Compose
docker-compose up

# Access services
# Frontend: http://localhost:3000
# API: http://localhost:5000
# Auth: http://localhost:4000
```

### Code Review Process

1. All PRs require at least one approval
2. CI/CD checks must pass
3. No merge conflicts
4. Documentation updated if needed
5. Squash and merge to keep history clean

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### MIT License Summary

- ✅ Commercial use
- ✅ Modification
- ✅ Distribution
- ✅ Private use
- ❌ Liability
- ❌ Warranty

---

## 📞 Support & Contact

### Getting Help

- **Documentation**: Check the [docs/](docs/) folder
- **Issues**: [Open an issue](https://github.com/John095/microservices-devops-aws/issues)
- **Discussions**: [GitHub Discussions](https://github.com/John095/microservices-devops-aws/discussions)
- **Email**: support@example.com

### Maintainers

- [@John095](https://github.com/John095) - Project Lead

---

## 🔗 Additional Resources

### AWS Documentation

- [ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest
