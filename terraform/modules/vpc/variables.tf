variable "vpc_name" {
    description = "Name of the VPC"
    type        = string
}

variable "vpc_cidr" {
    description = "CIDR block for VPC"
    type        = string
}

variable "availability_zones" {
    description = "List of availability zones"
    type        = list(string)
}

variable "trust_subnet_cidrs" {
    description = "Map of availability zones to trust subnet CIDR blocks"
    type        = map(string)
}

variable "private_subnet_cidrs" {
    description = "Map of availability zones to private subnet CIDR blocks"
    type        = map(string)
} 