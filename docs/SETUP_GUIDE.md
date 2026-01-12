# Complete Setup Guide

This guide will walk you through setting up the entire DevOps infrastructure from scratch.

## Prerequisites

Before starting, ensure you have the following installed:

- AWS Account with admin access
- Terraform >= 1.0
- Docker >= 20.10
- AWS CLI configured
- Node.js >= 18
- Git
- GitHub account

## Step 1: Clone and Setup Repository

```bash
# Create new repository on GitHub
# Clone it locally
git clone https://github.com/yourusername/microservices-devops-aws.git
cd microservices-devops-aws

# Copy all the project files to this directory
# (Use the structure provided in the documentation)
```

## Step 2: Configure AWS

### 2.1 Configure AWS CLI

```bash
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Default region: us-east-1
# Default output format: json
```

### 2.2 Create ECR Repositories

```bash
# Create ECR repositories for each service
aws ecr create-repository --repository-name api-service --region us-east-1
aws ecr create-repository --repository-name auth-service --region us-east-1
aws ecr create-repository --repository-name frontend --region us-east-1

# Get ECR registry URL
export ECR_REGISTRY=$(aws ecr describe-repositories --region us-east-1 --query 'repositories[0].repositoryUri' --output text | cut -d'/' -f1)
echo $ECR_REGISTRY
```

### 2.3 Create S3 Bucket for Terraform State

```bash
# Create bucket for Terraform state
aws s3 mb s3://your-terraform-state-bucket --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket your-terraform-state-bucket \
    --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking
aws dynamodb create-table \
    --table-name terraform-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region us-east-1
```

## Step 3: Configure Terraform

### 3.1 Update Backend Configuration

Edit `terraform/main.tf` and update the S3 backend:

```hcl
backend "s3" {
  bucket         = "your-actual-bucket-name"  # Change this
  key            = "microservices/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-lock"
}
```

### 3.2 Create terraform.tfvars

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
aws_region     = "us-east-1"
environment    = "prod"
project_name   = "microservices-app"
vpc_cidr       = "10.0.0.0/16"

# Database credentials
db_name     = "appdb"
db_username = "admin"
db_password = "ChangeThisToSecurePassword123!"  # Use a strong password

# ECR image URLs (update after building images)
api_image      = "123456789.dkr.ecr.us-east-1.amazonaws.com/api-service:latest"
auth_image     = "123456789.dkr.ecr.us-east-1.amazonaws.com/auth-service:latest"
frontend_image = "123456789.dkr.ecr.us-east-1.amazonaws.com/frontend:latest"
```

## Step 4: Build and Push Docker Images

### 4.1 Build Images Locally

```bash
# Build API service
cd services/api-service
docker build -t api-service:latest .

# Build Auth service
cd ../auth-service
docker build -t auth-service:latest .

# Build Frontend
cd ../frontend
docker build -t frontend:latest .
```

### 4.2 Login to ECR

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REGISTRY
```

### 4.3 Tag and Push Images

```bash
# API Service
docker tag api-service:latest $ECR_REGISTRY/api-service:latest
docker push $ECR_REGISTRY/api-service:latest

# Auth Service
docker tag auth-service:latest $ECR_REGISTRY/auth-service:latest
docker push $ECR_REGISTRY/auth-service:latest

# Frontend
docker tag frontend:latest $ECR_REGISTRY/frontend:latest
docker push $ECR_REGISTRY/frontend:latest
```

## Step 5: Deploy Infrastructure with Terraform

### 5.1 Initialize Terraform

```bash
cd terraform
terraform init
```

### 5.2 Plan Infrastructure

```bash
terraform plan -out=tfplan
```

Review the plan carefully to ensure everything looks correct.

### 5.3 Apply Infrastructure

```bash
terraform apply tfplan
```

This will take 10-15 minutes to create all resources. Terraform will create:

- VPC with public and private subnets
- NAT Gateway and Internet Gateway
- Security Groups
- Application Load Balancer
- ECS Cluster and Services
- RDS PostgreSQL Database
- S3 Bucket
- CloudWatch Log Groups
- IAM Roles and Policies

### 5.4 Get Outputs

```bash
terraform output
```

Save the ALB DNS name - this is your application URL.

## Step 6: Setup GitHub Actions CI/CD

### 6.1 Create GitHub Secrets

Go to your GitHub repository → Settings → Secrets and Variables → Actions

Add the following secrets:

- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
- `ECR_REGISTRY`: Your ECR registry URL
- `ECS_CLUSTER`: prod-cluster (or your cluster name)
- `SLACK_WEBHOOK`: (Optional) Your Slack webhook URL

### 6.2 Test CI/CD Pipeline

```bash
# Make a small change to trigger the pipeline
echo "# Test change" >> README.md
git add .
git commit -m "Test CI/CD pipeline"
git push origin main
```

Check the Actions tab in GitHub to see the pipeline running.

## Step 7: Verify Deployment

### 7.1 Check ECS Services

```bash
aws ecs list-services --cluster prod-cluster --region us-east-1
aws ecs describe-services --cluster prod-cluster --services prod-api --region us-east-1
```

### 7.2 Access the Application

```bash
# Get ALB DNS name
ALB_DNS=$(terraform output -raw alb_dns_name)
echo "Application URL: http://$ALB_DNS"

# Test health endpoint
curl http://$ALB_DNS/health
```

### 7.3 Check Logs

```bash
# View ECS logs
aws logs tail /ecs/prod --follow --region us-east-1
```

## Step 8: Configure Custom Domain (Optional)

### 8.1 Request ACM Certificate

```bash
aws acm request-certificate \
    --domain-name yourdomain.com \
    --validation-method DNS \
    --region us-east-1
```

### 8.2 Update Route 53

Create an A record pointing to your ALB:

```bash
# Get ALB Hosted Zone ID
ALB_ZONE_ID=$(terraform output -raw alb_zone_id)
ALB_DNS=$(terraform output -raw alb_dns_name)

# Create Route 53 record (adjust as needed)
aws route53 change-resource-record-sets \
    --hosted-zone-id YOUR_HOSTED_ZONE_ID \
    --change-batch file://route53-change.json
```

## Step 9: Setup Monitoring

### 9.1 Create CloudWatch Dashboard

```bash
# Create custom dashboard
aws cloudwatch put-dashboard \
    --dashboard-name prod-monitoring \
    --dashboard-body file://dashboard-config.json \
    --region us-east-1
```

### 9.2 Setup Alarms

Terraform already created CPU and Memory alarms. You can add more:

```bash
# Example: ALB 5XX errors alarm
aws cloudwatch put-metric-alarm \
    --alarm-name prod-alb-5xx-errors \
    --alarm-description "Alert on ALB 5XX errors" \
    --metric-name HTTPCode_Target_5XX_Count \
    --namespace AWS/ApplicationELB \
    --statistic Sum \
    --period 300 \
    --threshold 10 \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 1 \
    --region us-east-1
```

## Step 10: Testing

### 10.1 Run Local Tests

```bash
# Test with docker-compose
docker-compose up -d

# Run API tests
curl http://localhost:3000/health
curl http://localhost:3000/api/users

# Clean up
docker-compose down
```

### 10.2 Load Testing (Optional)

```bash
# Install Apache Bench
sudo apt-get install apache2-utils

# Run load test
ab -n 1000 -c 10 http://$ALB_DNS/health
```

## Troubleshooting

### Issue: Terraform Apply Fails

```bash
# Check AWS credentials
aws sts get-caller-identity

# Enable detailed logging
export TF_LOG=DEBUG
terraform apply
```

### Issue: ECS Tasks Not Starting

```bash
# Check task logs
aws ecs describe-tasks \
    --cluster prod-cluster \
    --tasks TASK_ID \
    --region us-east-1

# Check CloudWatch logs
aws logs tail /ecs/prod --follow
```

### Issue: Cannot Access Application

```bash
# Check ALB target health
aws elbv2 describe-target-health \
    --target-group-arn TARGET_GROUP_ARN \
    --region us-east-1

# Check security groups
aws ec2 describe-security-groups --region us-east-1
```

## Maintenance

### Update Services

```bash
# Build and push new image
docker build -t api-service:v2 .
docker tag api-service:v2 $ECR_REGISTRY/api-service:latest
docker push $ECR_REGISTRY/api-service:latest

# Deploy using script
./scripts/deploy.sh prod api
```

### Rollback Deployment

```bash
./scripts/rollback.sh prod api
```

### Scale Services

```bash
# Scale API service
aws ecs update-service \
    --cluster prod-cluster \
    --service prod-api \
    --desired-count 5 \
    --region us-east-1
```

## Cleanup

To destroy all resources:

```bash
cd terraform
terraform destroy
```

**WARNING**: This will delete all resources including the database!

## Cost Optimization

1. Use Fargate Spot for non-production environments
2. Enable ECS task auto-scaling
3. Use RDS instance right-sizing
4. Enable S3 lifecycle policies
5. Set up CloudWatch log retention

## Next Steps

1. Set up automated backups
2. Implement blue-green deployments
3. Add monitoring dashboards
4. Set up alerting to Slack/PagerDuty
5. Implement application-level metrics
6. Add WAF for security
7. Enable AWS X-Ray for tracing

## Support

For issues:

- Check the troubleshooting section
- Review CloudWatch logs
- Open an issue on GitHub
