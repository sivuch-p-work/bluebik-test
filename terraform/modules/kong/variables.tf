variable "cluster_name" {
  description = "Name of the Kong ECS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group"
  type        = string
}

variable "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "kong_db_host" {
  description = "Kong database host"
  type        = string
  default     = ""
}

variable "kong_db_name" {
  description = "Kong database name"
  type        = string
  default     = "kong"
}

variable "kong_db_user" {
  description = "Kong database user"
  type        = string
  default     = ""
}

variable "kong_db_password" {
  description = "Kong database password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "kong_db_port" {
  description = "Kong database port"
  type        = string
  default     = "5432"
}

variable "image_url" {
  description = "Kong Docker image URL"
  type        = string
  default     = "kong:latest"
}

variable "secrets_arn" {
  description = "ARN of the Secrets Manager secret containing Kong credentials"
  type        = string
} 