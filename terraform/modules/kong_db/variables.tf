variable "instance_name" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "trust_subnet_ids" {
    type = list(string)
    default= []
}

variable "private_security_group_id" {
    type = string
}

variable "trust_db_security_group_id" {
    type = string
    default= ""
}

variable "database_name" {
    type = string
    default= "kong"
}

variable "master_username" {
    type = string
    default= "kong"
}

variable "master_password" {
    type = string
    sensitive = true
} 