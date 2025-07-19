variable "cluster_name" {
  description = "Name of the Redis cluster"
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

variable "private_security_group_id" {
  description = "ID of the private security group"
  type        = string
} 