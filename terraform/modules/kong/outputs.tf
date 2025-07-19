output "cluster_id" {
  description = "ID of the Kong ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_arn" {
  description = "ARN of the Kong ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "service_id" {
  description = "ID of the Kong ECS service"
  value       = aws_ecs_service.main.id
} 