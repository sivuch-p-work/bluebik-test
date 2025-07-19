# BlueBik Terraform Infrastructure

This Terraform configuration sets up a complete infrastructure for a backend application with the following components:

## Architecture Overview

```
Internet
    ↓
ALB (Trust Subnet)
    ↓
Kong Gateway (Private Subnet)
    ↓
Backend Application (Private Subnet)
    ↓
Aurora PostgreSQL (Private/Trust Subnet)
Kong Database (Private/Trust Subnet)
Redis Cache (Private Subnet)
```

## Components

- **VPC** with Trust (Public) and Private subnets
- **Application Load Balancer** in Trust subnet
- **Kong API Gateway** in Private subnet
- **Backend Application** in Private subnet
- **Aurora PostgreSQL** cluster (configurable subnet placement)
- **Kong Database** (PostgreSQL RDS) (configurable subnet placement)
- **Redis Cache** in Private subnet
- **Secrets Manager** for secure credential storage

## Network Configuration

### Subnet Types

1. **Trust Subnets** (Public):
   - `172.25.170.192/27` (ap-southeast-1b)
   - `172.25.170.224/27` (ap-southeast-1c)
   - Has Internet Gateway for outbound internet access

2. **Private Subnets**:
   - `172.25.1.0/24` (ap-southeast-1b)
   - `172.25.2.0/24` (ap-southeast-1c)
   - Has NAT Gateway for outbound internet access

### Database Placement Options

You can choose where to deploy your databases:

#### Option 1: Private Subnet (Recommended for Production)
```hcl
use_trust_subnet_for_db = false
```
- **Aurora** and **Kong-DB** deployed in private subnets
- Better security isolation
- Databases not directly accessible from internet
- Kong and Backend can still connect via security groups

#### Option 2: Trust Subnet (For Development/Testing)
```hcl
use_trust_subnet_for_db = true
```
- **Aurora** and **Kong-DB** deployed in trust (public) subnets
- Easier direct access for development/debugging
- **Security Warning**: Databases will be in public subnets
- Kong and Backend can still connect via security groups

## Security Groups

### For Databases in Trust Subnet
- PostgreSQL port 5432 access from private security group only
- No direct internet access to databases
- Kong and Backend applications can still connect

### For Applications
- Kong and Backend can access databases regardless of placement
- ALB can route traffic to Kong
- Kong can route traffic to Backend

## Usage

1. **Configure Variables**:
   ```bash
   # Edit terraform.tfvars
   aurora_master_password = "your_secure_password"
   kong_db_password      = "your_secure_password"
   kong_secret_password  = "your_secure_password"
   
   # Choose database placement
   use_trust_subnet_for_db = false  # or true
   ```

2. **Initialize and Apply**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Security Considerations

### When using Trust Subnet for Databases:
- ✅ Kong and Backend can still connect via security groups
- ✅ No direct internet access to databases (only from private subnets)
- ⚠️ Databases are in public subnets (potential security risk)
- ⚠️ Consider using VPN or bastion host for database access

### When using Private Subnet for Databases:
- ✅ Maximum security isolation
- ✅ Databases completely isolated from internet
- ✅ Kong and Backend can still connect via security groups
- ✅ Recommended for production environments

## Connectivity Verification

After deployment, you can verify connectivity:

1. **Kong to Kong-DB**: Kong should be able to connect to Kong-DB regardless of subnet placement
2. **Backend to Aurora**: Backend should be able to connect to Aurora regardless of subnet placement
3. **ALB to Kong**: ALB should be able to route traffic to Kong
4. **Kong to Backend**: Kong should be able to route traffic to Backend

## Troubleshooting

If connectivity issues occur:

1. Check security group rules
2. Verify subnet route tables
3. Ensure database endpoints are correct
4. Check VPC DNS settings

## Requirements

- Terraform >= 1.0
- AWS Provider ~> 5.0
- AWS CLI configured with appropriate credentials 