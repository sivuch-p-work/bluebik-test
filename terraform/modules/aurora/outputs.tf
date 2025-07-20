output "cluster_endpoint" {
    value = aws_rds_cluster.main.endpoint
}

output "cluster_identifier" {
    value = aws_rds_cluster.main.cluster_identifier
}

output "database_name" {
    value = aws_rds_cluster.main.database_name
}

output "master_username" {
    value = aws_rds_cluster.main.master_username
}