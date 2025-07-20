# Terraform Infrastructure for Backend Services

This Terraform configuration sets up a complete backend infrastructure with Kong API Gateway, Aurora PostgreSQL, Redis, and application services.

## Architecture

- **VPC**: Custom VPC with public and private subnets across multiple AZs
- **ALB**: Application Load Balancer for traffic distribution
- **Kong**: API Gateway running on ECS Fargate
- **Aurora**: PostgreSQL database cluster
- **Redis**: ElastiCache for Redis
- **Secrets Manager**: Secure storage for sensitive configuration

## Module Integration

### Secrets Manager Integration

The `secrets` module is now fully integrated with the `kong` module:

1. **Secrets Storage**: Kong database credentials are stored in AWS Secrets Manager
2. **IAM Permissions**: ECS execution role has permissions to access secrets
3. **Runtime Access**: Kong containers retrieve credentials from Secrets Manager at runtime

#### Security Benefits

- Database passwords are not stored in plain text in Terraform state
- Credentials are automatically rotated and managed by AWS
- Access is controlled through IAM policies
- Secrets are encrypted at rest

#### Configuration Flow

1. `kong_db` module creates the PostgreSQL database
2. `secrets` module stores database credentials in Secrets Manager
3. `kong` module retrieves credentials from Secrets Manager at runtime
4. Kong containers use the retrieved credentials to connect to the database

## Usage

### Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- Required variables set in `terraform.tfvars`

### Required Variables

```hcl
aurora_master_password = "your-aurora-password"
kong_db_password       = "your-kong-db-password"
kong_secret_password   = "your-kong-secret-password"
```

### Deployment

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

## Module Dependencies

```
vpc
├── alb
├── kong_db
│   └── secrets
│       └── kong
├── aurora
└── redis
```

## Security Considerations

- All sensitive data is stored in AWS Secrets Manager
- Database instances are in private subnets
- Security groups restrict access appropriately
- ECS tasks use least-privilege IAM roles 