variable "secret_name" {
    description = "Name of the secret in AWS Secrets Manager"
    type        = string
}

variable "kong_user" {
    description = "Kong database username"
    type        = string
    default     = "kong"
}

variable "kong_password" {
    description = "Kong database password"
    type        = string
    default     = "mypassword"
    #   sensitive   = true
}

variable "kong_postgres_url" {
    description = "Kong PostgreSQL connection URL"
    type        = string
    default     = ""
} 