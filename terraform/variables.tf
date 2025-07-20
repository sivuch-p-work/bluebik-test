variable "aws_region" {
    type = string
    default = "ap-southeast-1"
}

variable "environment" {
    type = string
    default = "production"
}

variable "aurora_master_password" {
    type = string
    sensitive = true
}

variable "kong_db_password" {
    type = string
    sensitive= true
}

variable "kong_secret_password" {
    type = string
    sensitive= true
}

variable "is_override_kong_custom_image_used" {
    type = bool
    default = false
}

variable "secret_manager_kong_arn" {
    type = string
    default = ""
}

variable "kong_custom_image_url" {
    type = string
    default = ""
}

variable "backend_image_url" {
    type = string
}