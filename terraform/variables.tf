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

variable "is_override_kong_custom_image_used" {
    description = "Whether to use the official Kong image"
    type        = bool
    default     = false
}

variable "secret_manager_kong_arn" {
    description = "ARN of the secret manager for Kong"
    type        = string
    default     = ""
}

variable "kong_custom_image_url" {
    description = "URL of the custom Kong image"
    type        = string
    default     = ""
}

variable "backend_image_url" {
    description = "URL of the custom backend image"
    type        = string
}