output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "aurora_endpoint" {
  description = "Aurora cluster endpoint"
  value       = module.aurora.cluster_endpoint
}

output "kong_db_endpoint" {
  description = "Kong database endpoint"
  value       = module.kong_db.endpoint
}

output "redis_endpoint" {
  description = "Redis cluster endpoint"
  value       = module.redis.cache_cluster_address
}

output "kong_secret_arn" {
  description = "ARN of the Kong secret"
  value       = module.secrets.secret_arn
}