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

variable "db_host" {
    type = string
    default = ""
}

variable "db_port" {
    type = string
    default = "5432"
}

variable "db_name" {
    type = string
    default = ""
}

variable "db_user" {
    type = string
    default = ""
}

variable "db_password" {
    type = string
    default = ""
}

variable "redis_host" {
    type = string
    default = ""
}

variable "redis_port" {
    type = string
    default = "6379"
}

variable "image_url" {
    type = string
    default = ""
}