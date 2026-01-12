# Deployment Guide

## Prerequisites

- AWS CLI
- Terraform
- Docker
- GitHub repo with Actions

## Steps

1. Copy `terraform.tfvars.example` → `dev/terraform.tfvars`
2. Run `./scripts/setup-aws.sh`
3. Push to `main` → CI/CD triggers
4. View ALB DNS in Terraform output
