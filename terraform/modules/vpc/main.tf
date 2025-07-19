# VPC
resource "aws_vpc" "main" {
    cidr_block           = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
        Name = var.vpc_name
    }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.vpc_name}-igw"
    }
}

# Trust Subnets (Public)
resource "aws_subnet" "trust" {
    for_each = var.trust_subnet_cidrs

    vpc_id                  = aws_vpc.main.id
    cidr_block              = each.value
    availability_zone       = each.key
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.vpc_name}-trust-subnet-${substr(each.key, -1, 1)}"
    }
}

# Private Subnets
resource "aws_subnet" "private" {
    for_each = var.private_subnet_cidrs

    vpc_id            = aws_vpc.main.id
    cidr_block        = each.value
    availability_zone = each.key

    tags = {
        Name = "${var.vpc_name}-private-subnet-${substr(each.key, -1, 1)}"
    }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
    domain = "vpc"
    depends_on = [aws_internet_gateway.main]

    tags = {
        Name = "${var.vpc_name}-nat-eip"
    }
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.nat.id
    subnet_id     = aws_subnet.trust["ap-southeast-1b"].id

    tags = {
        Name = "${var.vpc_name}-nat-gateway"
    }

    depends_on = [aws_internet_gateway.main]
}

# Route Table for Trust Subnets
resource "aws_route_table" "trust" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
        Name = "${var.vpc_name}-trust-rt"
    }
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.main.id
    }

    tags = {
        Name = "${var.vpc_name}-private-rt"
    }
}

# Route Table Associations for Trust Subnets
resource "aws_route_table_association" "trust" {
    for_each = aws_subnet.trust

    subnet_id      = each.value.id
    route_table_id = aws_route_table.trust.id
}

# Route Table Associations for Private Subnets
resource "aws_route_table_association" "private" {
    for_each = aws_subnet.private

    subnet_id      = each.value.id
    route_table_id = aws_route_table.private.id
}

# Security Groups for ALB
resource "aws_security_group" "alb" {
    name        = "${var.vpc_name}-alb-sg"
    description = "Security group for ALB"
    vpc_id      = aws_vpc.main.id

    ingress {
        description = "HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTPS"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.vpc_name}-alb-sg"
    }
}

# Security Groups for Private
resource "aws_security_group" "private" {
    name        = "${var.vpc_name}-private-sg"
    description = "Security group for private resources"
    vpc_id      = aws_vpc.main.id

    ingress {
        description     = "All traffic from ALB"
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        security_groups = [aws_security_group.alb.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.vpc_name}-private-sg"
    }
}

# Security Groups for Database in Trust Subnet
resource "aws_security_group" "trust_db" {
    name        = "${var.vpc_name}-trust-db-sg"
    description = "Security group for database in trust subnet"
    vpc_id      = aws_vpc.main.id

    ingress {
        description     = "PostgreSQL from private subnets"
        from_port       = 5432
        to_port         = 5432
        protocol        = "tcp"
        security_groups = [aws_security_group.private.id]
    }

    # Optional: Allow specific IP ranges for database access
    # ingress {
    #     description = "PostgreSQL from specific IPs"
    #     from_port   = 5432
    #     to_port     = 5432
    #     protocol    = "tcp"
    #     cidr_blocks = ["YOUR_IP_RANGE/32"]
    # }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.vpc_name}-trust-db-sg"
    }
} 