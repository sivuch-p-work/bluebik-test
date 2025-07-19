output "secret_arn" {
    description = "ARN of the Kong secret"
    value       = aws_secretsmanager_secret.kong.arn
}

output "secret_name" {
    description = "Name of the Kong secret"
    value       = aws_secretsmanager_secret.kong.name
} 