variable "instance_name" {
    description = "Name of the RDS instance"
    type        = string
}

variable "vpc_id" {
    description = "ID of the VPC"
    type        = string
}

variable "trust_subnet_ids" {
    description = "List of trust subnet IDs (optional)"
    type        = list(string)
    default     = []
}

variable "private_security_group_id" {
    description = "ID of the private security group"
    type        = string
}

variable "trust_db_security_group_id" {
    description = "ID of the trust database security group (optional)"
    type        = string
    default     = ""
}

variable "master_username" {
    description = "Master username for RDS instance"
    type        = string
    default     = "kong"
}

variable "master_password" {
    description = "Master password for RDS instance"
    type        = string
    sensitive   = true
} 