#!/bin/bash

# Get ECR repository URL from Terraform output
# ECR_REPO_URL=$(cd terraform && terraform output -raw kong_repository_url)
ECR_REPO_URL="644789170005.dkr.ecr.ap-southeast-1.amazonaws.com"
ECR_REPO_NAME="kong"
VERSION="latest"

if [ -z "$ECR_REPO_URL" ]; then
    echo "Error: Could not get ECR repository URL from Terraform output"
    exit 1
fi

echo "ECR Repository URL: $ECR_REPO_URL"

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region ap-southeast-1 --profile bluebik | docker login --username AWS --password-stdin $ECR_REPO_URL

# Pull Kong image from Docker Hub
echo "Pulling Kong image from Docker Hub..."
# docker pull kong:latest
docker build -t kong:latest .

# Tag the image for ECR
echo "Tagging Kong image for ECR..."
docker tag kong:$VERSION $ECR_REPO_URL/$ECR_REPO_NAME:$VERSION

# Push to ECR
echo "Pushing Kong image to ECR..."
docker push $ECR_REPO_URL/$ECR_REPO_NAME:$VERSION

echo "Successfully pushed Kong image to ECR!"
echo "Image URL: $ECR_REPO_URL/$ECR_REPO_NAME:$VERSION" 