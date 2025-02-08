# The Cool AI System

## Overview

The Cool AI System deploys a Dockerized AI application to AWS. It uses:
- **ECR** to store Docker images.
- **ECS** to run containers.
- **Terraform** (run locally) to provision infrastructure (VPC, subnets, security groups, ALB, etc.).
- **GitHub Actions** to automate building and pushing Docker images.

The ECS cluster itself is created manually.

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/the-cool-ai-system.git
cd the-cool-ai-system
```

### 2. Create IAM Users

#### 2.1 Local Terraform User  
Create an IAM user (e.g., `terraform-user`) with the permissions needed to create services in .tf files.

Download its access keys and configure your local AWS CLI or environment variables accordingly.

#### 2.2 GitHub Actions User  
Create another IAM user (e.g., github-actions) with the following permissions:
```
AmazonEC2ContainerRegistryPowerUser
"ecr:CreateRepository"
"ecr:TagResource"

with "Resource": "*"
```

Download the access keys for this user.

### 3. Configure AWS Credentials for GitHub Actions

In your GitHub repository, navigate to **Settings > Secrets and variables > Actions** and add these secrets (using the \`github-actions\` credentials):

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION 

### 4. Initialize Terraform Locally

Ensure Terraform is installed on your local machine and then run:

```bash
terraform init
```

Configure your local environment with the credentials from the terraform-user (via environment variables or the AWS CLI).

### 5. GitHub Actions Workflow

The CI/CD pipeline will:
1. Check out the code.
2. Configure AWS credentials (from GitHub Secrets).
3. Create the ECR repository (if it doesn’t exist) using a GitHub Action.
4. Run Terraform to apply the ECR resource.
5. Build and push the Docker image to ECR.


### 6. Manual ECS Cluster Setup

Since the ECS cluster is created manually, follow these steps using the AWS Console or your local setup:
- Create an ECS cluster (e.g., `the-cool-ai-cluster`) using Fargate if desired.
- Define task definitions and create the ECS service.
- Configure associated VPC resources (subnets, security groups, ALB, Internet Gateway, and Route Tables) as specified in your Terraform configuration.

## Summary

- **Local Terraform** provisions infrastructure (ECR, VPC, subnets, security groups, ALB, etc.).
- **GitHub Actions** automates building and pushing Docker images and applies the ECR resource.
- **Manual Setup** is required for creating the ECS cluster and related configurations via the AWS Console.