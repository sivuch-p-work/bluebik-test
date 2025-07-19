output "cache_nodes" {
  description = "List of node objects including an id, address, port and availability_zone"
  value       = aws_elasticache_cluster.main.cache_nodes
}

output "configuration_endpoint" {
  description = "The configuration endpoint to allow host discovery"
  value       = aws_elasticache_cluster.main.configuration_endpoint
}

output "cache_cluster_address" {
  description = "The DNS name of the cache cluster"
  value       = aws_elasticache_cluster.main.cache_nodes[0].address
} 