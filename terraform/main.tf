terraform {
    required_version = ">= 1.0"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    profile = "bluebik"
    region = "ap-southeast-1"
    
    default_tags {
        tags = {
            Project     = "backend-vpc"
            Environment = "production"
            ManagedBy   = "terraform"
        }
    }
}

# VPC and Networking
module "vpc" {
    source = "./modules/vpc"
    
    vpc_name = "backend-vpc"
    vpc_cidr = "172.25.0.0/16"
    
    availability_zones = ["ap-southeast-1b", "ap-southeast-1c"]
    
    trust_subnet_cidrs = {
        "ap-southeast-1b" = "172.25.170.192/27"
        "ap-southeast-1c" = "172.25.170.224/27"
    }
    
    private_subnet_cidrs = {
        "ap-southeast-1b" = "172.25.1.0/24"
        "ap-southeast-1c" = "172.25.2.0/24"
    }
}

# Application Load Balancer
module "alb" {
    source = "./modules/alb"
    
    name                = "backend-alb"
    vpc_id              = module.vpc.vpc_id
    public_subnet_ids   = module.vpc.trust_subnet_ids
    security_group_id   = module.vpc.alb_security_group_id
    
    depends_on = [module.vpc]
}

# Kong Database
module "kong_db" {
    source = "./modules/kong_db"
    
    instance_name               = "kong-db-instance"
    vpc_id                      = module.vpc.vpc_id
    trust_subnet_ids            = module.vpc.trust_subnet_ids
    private_security_group_id   = module.vpc.private_security_group_id
    trust_db_security_group_id  = module.vpc.trust_db_security_group_id
    database_name               = "kong"
    master_username             = "kong"
    master_password             = var.kong_db_password
    
    depends_on = [module.vpc]
}

# Aurora PostgreSQL Database
module "aurora" {
    source = "./modules/aurora"
    
    cluster_name                = "app-aurora"
    vpc_id                      = module.vpc.vpc_id
    trust_subnet_ids            = module.vpc.trust_subnet_ids
    private_security_group_id   = module.vpc.private_security_group_id
    trust_db_security_group_id  = module.vpc.trust_db_security_group_id
    master_password             = var.aurora_master_password
    
    depends_on = [module.vpc]
}

# Redis Cache
module "redis" {
    source = "./modules/redis"
    
    cluster_name                = "redis"
    vpc_id                      = module.vpc.vpc_id
    private_subnet_ids          = [module.vpc.private_subnet_ids["ap-southeast-1c"]]
    private_security_group_id   = module.vpc.private_security_group_id
    
    depends_on = [module.vpc]
}

# # Secrets Manager
# module "secrets" {
#     source = "./modules/secrets"
    
#     secret_name         = "kong-secrets"
#     kong_user           = module.kong_db.username
#     kong_password       = var.kong_secret_password
#     kong_postgres_url   = "postgresql://${module.kong_db.username}:${var.kong_secret_password}@${module.kong_db.endpoint}:${module.kong_db.port}/${module.kong_db.database_name}"
    
#     depends_on = [module.kong_db]
# }

# Kong Cluster
module "kong" {
    source = "./modules/kong"
    
    cluster_name            = "kong-cluster"
    vpc_id                  = module.vpc.vpc_id
    private_subnet_ids      = [module.vpc.private_subnet_ids["ap-southeast-1b"]]
    security_group_id       = module.vpc.private_security_group_id
    alb_target_group_arn    = module.alb.kong_target_group_arn
    kong_db_host            = module.kong_db.host
    kong_db_port            = module.kong_db.port
    kong_db_name            = module.kong_db.database_name
    kong_db_user            = module.kong_db.username
    kong_db_password        = var.kong_db_password

    image_url               = var.is_override_kong_custom_image_used && var.kong_custom_image_url != "" ? var.kong_custom_image_url : "kong:3.9.1"
    secrets_arn             = var.secret_manager_kong_arn
    
    depends_on = [module.vpc, module.alb, module.kong_db]
}

# Backend Cluster
module "backend" {
    source = "./modules/backend"
    
    cluster_name            = "backend-cluster"
    vpc_id                  = module.vpc.vpc_id
    private_subnet_ids      = [module.vpc.private_subnet_ids["ap-southeast-1b"]]
    security_group_id       = module.vpc.private_security_group_id
    alb_target_group_arn    = module.alb.backend_target_group_arn

    db_host     = module.aurora.cluster_endpoint
    db_port     = "5432"
    db_name     = module.aurora.database_name
    db_user     = module.aurora.master_username
    db_password = var.aurora_master_password

    image_url   = var.backend_image_url

    redis_host  = module.redis.cache_cluster_address
    redis_port  = "6379"
    
    depends_on = [module.vpc, module.alb, module.aurora]
}