# DB Subnet Group
resource "aws_db_subnet_group" "main" {
    name       = "${var.instance_name}-subnet-group"
    subnet_ids = var.trust_subnet_ids

    tags = {
        Name = "${var.instance_name}-subnet-group"
    }
}

# Security Group
resource "aws_security_group" "main" {
    name        = "${var.instance_name}-sg"
    description = "Security group for Kong database"
    vpc_id      = var.vpc_id

    ingress {
        description     = "PostgreSQL from private subnets"
        from_port       = 5432
        to_port         = 5432
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
        Name = "${var.instance_name}-sg"
    }
}

# RDS Instance
resource "aws_db_instance" "main" {
    identifier           = var.instance_name
    engine               = "postgres"
    instance_class       = "db.t3.micro"
    allocated_storage    = 20
    storage_type         = "gp2"
    storage_encrypted    = true
    
    db_name              = "kong"
    username             = var.master_username
    password             = var.master_password
    
    vpc_security_group_ids = [aws_security_group.main.id]
    db_subnet_group_name   = aws_db_subnet_group.main.name
    
    backup_retention_period = 7
    backup_window          = "03:00-04:00"
    maintenance_window     = "sun:04:00-sun:05:00"
    
    skip_final_snapshot = true
    deletion_protection = false

    tags = {
        Name = var.instance_name
    }
}