#!/bin/bash
ENV=${1:-dev}
IMAGE_TAG=${IMAGE_TAG:-latest}

echo "Deploying to $ENV with tag $IMAGE_TAG"

cd terraform/environments/$ENV
terraform init
terraform apply -auto-approve -var "image_tag=$IMAGE_TAG"