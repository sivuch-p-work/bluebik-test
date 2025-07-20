output "secret_arn" {
  description = "ARN of the created secret"
  value       = aws_secretsmanager_secret.kong.arn
}

output "secret_id" {
  description = "ID of the created secret"
  value       = aws_secretsmanager_secret.kong.id
} 