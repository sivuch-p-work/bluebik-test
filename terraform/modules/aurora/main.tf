# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.cluster_name}-subnet-group"
  subnet_ids = var.trust_subnet_ids

  tags = {
    Name = "${var.cluster_name}-subnet-group"
  }
}

# Security Group
resource "aws_security_group" "main" {
    name        = "${var.cluster_name}-sg"
    description = "Security group for Aurora cluster"
    vpc_id      = var.vpc_id

    ingress {
        description     = "PostgreSQL from private subnets"
        from_port       = 5432
        to_port         = 5432
        protocol        = "tcp"
        security_groups = [var.private_security_group_id]
    }

    #   ingress {
    #     description     = "PostgreSQL from trust subnets"
    #     from_port       = 5432
    #     to_port         = 5432
    #     protocol        = "tcp"
    #     security_groups = [var.trust_db_security_group_id]
    #   }

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

# Aurora Cluster
resource "aws_rds_cluster" "main" {
    cluster_identifier     = var.cluster_name
    engine                = "aurora-postgresql"
    engine_version        = "15.4"
    database_name         = "appdb"
    master_username       = var.master_username
    master_password       = var.master_password
    skip_final_snapshot   = true
    db_subnet_group_name  = aws_db_subnet_group.main.name
    vpc_security_group_ids = [aws_security_group.main.id]

    tags = {
        Name = var.cluster_name
    }
}

# Aurora Instance
resource "aws_rds_cluster_instance" "main" {
    count               = 2
    identifier          = "${var.cluster_name}-instance-${count.index + 1}"
    cluster_identifier  = aws_rds_cluster.main.id
    instance_class      = "db.r6g.large"
    engine              = aws_rds_cluster.main.engine
    engine_version      = aws_rds_cluster.main.engine_version

    tags = {
        Name = "${var.cluster_name}-instance-${count.index + 1}"
    }
}