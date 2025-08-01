output "cluster_id" {
    value = aws_ecs_cluster.main.id
}

output "cluster_arn" {
    value = aws_ecs_cluster.main.arn
}

output "service_id" {
    value = aws_ecs_service.main.id
} 