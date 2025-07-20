resource "aws_elasticache_subnet_group" "main" {
    name       = "${var.cluster_name}-subnet-group"
    subnet_ids = var.private_subnet_ids

    tags = {
        Name = "${var.cluster_name}-subnet-group"
    }
}

resource "aws_elasticache_parameter_group" "main" {
    name   = "${var.cluster_name}-params"
    family = var.family

    tags = {
        Name = "${var.cluster_name}-params"
    }
}

resource "aws_elasticache_cluster" "main" {
    cluster_id           = var.cluster_name
    engine               = "redis"
    node_type            = "cache.t3.micro"
    num_cache_nodes      = 1
    parameter_group_name = aws_elasticache_parameter_group.main.name
    subnet_group_name    = aws_elasticache_subnet_group.main.name
    security_group_ids   = [aws_security_group.main.id]
    port                 = 6379

    tags = {
        Name = var.cluster_name
    }
}

resource "aws_security_group" "main" {
    name        = "${var.cluster_name}-sg"
    vpc_id      = var.vpc_id

    ingress {
        from_port       = 6379
        to_port         = 6379
        protocol        = "tcp"
        security_groups = [var.private_security_group_id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.cluster_name}-sg"
    }
} 