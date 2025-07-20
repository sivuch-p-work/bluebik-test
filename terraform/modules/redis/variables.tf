variable "cluster_name" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "private_subnet_ids" {
    type = list(string)
}

variable "private_security_group_id" {
    type = string
} 

variable "family" {
    type = string
    default = "redis7"
}