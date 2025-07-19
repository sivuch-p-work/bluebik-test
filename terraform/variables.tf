variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "aurora_master_password" {
    description = "Master password for Aurora PostgreSQL cluster"
    type        = string
    sensitive   = true
}

variable "kong_db_password" {
    description = "Master password for Kong database"
    type        = string
    sensitive   = true
}

variable "kong_secret_password" {
    description = "Password for Kong secrets"
    type        = string
    sensitive   = true
}