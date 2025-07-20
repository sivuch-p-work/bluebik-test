# AWS Configuration
aws_region = "ap-southeast-1"
environment = "production"

# Database Passwords (REQUIRED - Change these values)
aurora_master_password = "mypassword"
kong_db_password      = "mypassword"
kong_secret_password  = "mypassword"

secret_manager_kong_arn = "arn:aws:secretsmanager:ap-southeast-1:644789170005:secret:kong-secrets-storage-v9xPKX"

kong_custom_image_url = "644789170005.dkr.ecr.ap-southeast-1.amazonaws.com/kong:3.9.1"
is_override_kong_custom_image_used = true

backend_image_url = "image_url"