output "vpc_id" {
    value = aws_vpc.main.id
}

output "trust_subnet_ids" {
    value = values(aws_subnet.trust)[*].id
}

output "private_subnet_ids" {
    value = { for k, v in aws_subnet.private : k => v.id }
}

output "alb_security_group_id" {
    value = aws_security_group.alb.id
}

output "private_security_group_id" {
    value = aws_security_group.private.id
}

output "trust_db_security_group_id" {
    value = aws_security_group.trust_db.id
} 