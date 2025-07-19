output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "trust_subnet_ids" {
  description = "List of trust subnet IDs"
  value       = values(aws_subnet.trust)[*].id
}

output "private_subnet_ids" {
  description = "Map of availability zones to private subnet IDs"
  value       = { for k, v in aws_subnet.private : k => v.id }
}

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "private_security_group_id" {
  description = "ID of the private security group"
  value       = aws_security_group.private.id
}

output "trust_db_security_group_id" {
  description = "ID of the trust database security group"
  value       = aws_security_group.trust_db.id
} 