variable "vpc_name" {
    type = string
}

variable "vpc_cidr" {
    type = string
}

variable "availability_zones" {
    type = list(string)
}

variable "trust_subnet_cidrs" {
    type = map(string)
}

variable "private_subnet_cidrs" {
    type = map(string)
} 