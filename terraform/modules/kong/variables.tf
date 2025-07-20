variable "cluster_name" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "private_subnet_ids" {
    type = list(string)
}

variable "security_group_id" {
    type = string
}

variable "alb_target_group_arn" {
    type = string
}

variable "kong_db_host" {
    type = string
    default = ""
}

variable "kong_db_name" {
    type = string
    default = "kong"
}

variable "kong_db_user" {
    type = string
}

variable "kong_db_password" {
    type = string
    default = ""
    sensitive = true
}

variable "kong_db_port" {
    type = string
    default = "5432"
}

variable "image_url" {
    type = string
    default = ""
}

variable "secrets_arn" {
    type = string
} 