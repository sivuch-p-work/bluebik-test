output "vpc_id" {
    value = module.vpc.vpc_id
}

output "alb_dns_name" {
    value = module.alb.alb_dns_name
}

output "aurora_endpoint" {
    value = module.aurora.cluster_endpoint
}

output "kong_db_endpoint" {
    value = module.kong_db.endpoint
}

output "redis_endpoint" {
    value = module.redis.cache_cluster_address
}