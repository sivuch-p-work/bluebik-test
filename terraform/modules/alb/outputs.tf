output "alb_arn" {
    value = aws_lb.main.arn
}

output "alb_dns_name" {
    value = aws_lb.main.dns_name
}

output "backend_target_group_arn" {
    value = aws_lb_target_group.backend.arn
}

output "kong_target_group_arn" {
    value = aws_lb_target_group.kong.arn
} 