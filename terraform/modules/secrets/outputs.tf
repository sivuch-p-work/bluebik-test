output "secret_arn" {
    value = aws_secretsmanager_secret.kong.arn
}

output "secret_id" {
    value = aws_secretsmanager_secret.kong.id
} 