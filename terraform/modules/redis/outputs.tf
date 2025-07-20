output "cache_nodes" {
    value = aws_elasticache_cluster.main.cache_nodes
}

output "configuration_endpoint" {
    value = aws_elasticache_cluster.main.configuration_endpoint
}

output "cache_cluster_address" {
    value = aws_elasticache_cluster.main.cache_nodes[0].address
} 