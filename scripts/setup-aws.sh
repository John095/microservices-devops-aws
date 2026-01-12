#!/bin/bash

# AWS Infrastructure Setup Script
# This script sets up the complete microservices infrastructure on AWS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="microservices-devops"
AWS_REGION="us-east-1"
ENVIRONMENT="${1:-dev}"

echo -e "${BLUE}🚀 Setting up AWS infrastructure for ${PROJECT_NAME}...${NC}"
echo -e "${BLUE}Environment: ${ENVIRONMENT}${NC}"
echo -e "${BLUE}Region: ${AWS_REGION}${NC}"

# Check prerequisites
echo -e "\n${YELLOW}📋 Checking prerequisites...${NC}"

command -v aws >/dev/null 2>&1 || { echo -e "${RED}❌ AWS CLI is required but not installed.${NC}" >&2; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo -e "${RED}❌ Terraform is required but not installed.${NC}" >&2; exit 1; }
command -v docker >/dev/null 2>&1 || { echo -e "${RED}❌ Docker is required but not installed.${NC}" >&2; exit 1; }

echo -e "${GREEN}✅ All prerequisites met${NC}"

# Check AWS credentials
echo -e "\n${YELLOW}🔐 Checking AWS credentials...${NC}"
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo -e "${RED}❌ AWS credentials not configured. Run 'aws configure' first.${NC}"
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo -e "${GREEN}✅ AWS credentials configured for account: ${AWS_ACCOUNT_ID}${NC}"

# Create ECR repositories if they don't exist
echo -e "\n${YELLOW}📦 Creating ECR repositories...${NC}"
for service in api-service auth-service frontend; do
    if ! aws ecr describe-repositories --repository-names "${PROJECT_NAME}/${service}" --region ${AWS_REGION} >/dev/null 2>&1; then
        echo -e "${BLUE}Creating ECR repository: ${PROJECT_NAME}/${service}${NC}"
        aws ecr create-repository \
            --repository-name "${PROJECT_NAME}/${service}" \
            --region ${AWS_REGION} \
            --image-scanning-configuration scanOnPush=true >/dev/null
    else
        echo -e "${GREEN}✅ ECR repository ${PROJECT_NAME}/${service} already exists${NC}"
    fi
done

# Build and push Docker images
echo -e "\n${YELLOW}🐳 Building and pushing Docker images...${NC}"

# Login to ECR
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Build and push each service
for service in api-service auth-service frontend; do
    echo -e "${BLUE}Building ${service}...${NC}"
    docker build -t ${service} ./services/${service}
    
    echo -e "${BLUE}Tagging ${service}...${NC}"
    docker tag ${service}:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}/${service}:latest
    
    echo -e "${BLUE}Pushing ${service}...${NC}"
    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT_NAME}/${service}:latest
done

echo -e "${GREEN}✅ All Docker images built and pushed${NC}"

# Initialize and apply Terraform
echo -e "\n${YELLOW}🏗️  Deploying infrastructure with Terraform...${NC}"

cd terraform

# Initialize Terraform
echo -e "${BLUE}Initializing Terraform...${NC}"
terraform init

# Create terraform.tfvars if it doesn't exist
if [ ! -f "terraform.tfvars" ]; then
    echo -e "${BLUE}Creating terraform.tfvars from example...${NC}"
    cp terraform.tfvars.example terraform.tfvars
    
    # Update with actual values
    sed -i "s/myapp/${PROJECT_NAME}/g" terraform.tfvars
    
    echo -e "${YELLOW}⚠️  Please update terraform.tfvars with your actual values before continuing.${NC}"
    echo -e "${YELLOW}Press Enter to continue after updating the file...${NC}"
    read -r
fi

# Plan Terraform
echo -e "${BLUE}Planning Terraform deployment...${NC}"
terraform plan -var="environment=${ENVIRONMENT}"

# Apply Terraform
echo -e "${YELLOW}Do you want to apply these changes? (y/N): ${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${BLUE}Applying Terraform configuration...${NC}"
    terraform apply -auto-approve -var="environment=${ENVIRONMENT}"
    
    # Get outputs
    ALB_DNS=$(terraform output -raw alb_dns_name)
    
    echo -e "\n${GREEN}🎉 Infrastructure deployment completed!${NC}"
    echo -e "${GREEN}Application URL: http://${ALB_DNS}${NC}"
    echo -e "${GREEN}API Health Check: http://${ALB_DNS}/api/health${NC}"
    echo -e "${GREEN}Auth Health Check: http://${ALB_DNS}/auth/health${NC}"
    
    # Wait for services to be healthy
    echo -e "\n${YELLOW}⏳ Waiting for services to be healthy...${NC}"
    sleep 60
    
    # Test endpoints
    echo -e "\n${YELLOW}🧪 Testing endpoints...${NC}"
    
    if curl -f "http://${ALB_DNS}/api/health" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ API service is healthy${NC}"
    else
        echo -e "${RED}❌ API service is not responding${NC}"
    fi
    
    if curl -f "http://${ALB_DNS}/auth/health" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Auth service is healthy${NC}"
    else
        echo -e "${RED}❌ Auth service is not responding${NC}"
    fi
    
    if curl -f "http://${ALB_DNS}/" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Frontend is healthy${NC}"
    else
        echo -e "${RED}❌ Frontend is not responding${NC}"
    fi
    
else
    echo -e "${YELLOW}Deployment cancelled.${NC}"
fi

cd ..

echo -e "\n${GREEN}🏁 Setup completed!${NC}"
