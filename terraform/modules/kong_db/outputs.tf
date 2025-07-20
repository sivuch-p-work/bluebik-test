output "endpoint" {
  description = "Kong database endpoint"
  value       = aws_db_instance.main.endpoint
}

output "host" {
  description = "Kong database host"
  value       = aws_db_instance.main.address
}

output "port" {
  description = "Kong database port"
  value       = aws_db_instance.main.port
}

output "database_name" {
  description = "Kong database name"
  value       = aws_db_instance.main.db_name
}

output "username" {
  description = "Kong database username"
  value       = aws_db_instance.main.username
} 