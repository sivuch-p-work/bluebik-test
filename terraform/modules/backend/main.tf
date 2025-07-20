# IAM Role for ECS Execution
resource "aws_iam_role" "ecs_execution_role" {
    name = "${var.cluster_name}-execution-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
    role       = aws_iam_role.ecs_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Role for ECS Task
resource "aws_iam_role" "ecs_task_role" {
    name = "${var.cluster_name}-task-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
            }
        ]
    })
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "main" {
    name              = "/ecs/${var.cluster_name}"
    retention_in_days = 7

    tags = {
        Name = "${var.cluster_name}-logs"
    }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
    name = var.cluster_name

    setting {
        name  = "containerInsights"
        value = "enabled"
    }

    tags = {
        Name = var.cluster_name
    }
}

# Task Definition
resource "aws_ecs_task_definition" "main" {
    family                   = "${var.cluster_name}-task"
    network_mode             = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu                      = 512
    memory                   = 1024
    execution_role_arn       = aws_iam_role.ecs_execution_role.arn
    task_role_arn            = aws_iam_role.ecs_task_role.arn

    container_definitions = jsonencode([
        {
            name  = "backend"
            image = var.image_url
            
            portMappings = [
                {
                    containerPort = 8080
                    protocol      = "tcp"
                }
            ]

            environment = [
                {
                    name  = "DB_HOST"
                    value = var.db_host
                },
                {
                    name  = "DB_PORT"
                    value = var.db_port
                },
                {
                    name  = "DB_NAME"
                    value = var.db_name
                },
                {
                    name  = "DB_USER"
                    value = var.db_user
                },
                {
                    name  = "DB_PASSWORD"
                    value = var.db_password
                },
                {
                    name  = "REDIS_HOST"
                    value = var.redis_host
                },
                {
                    name  = "REDIS_PORT"
                    value = var.redis_port
                }
            ]

            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    awslogs-group         = aws_cloudwatch_log_group.main.name
                    awslogs-region        = "ap-southeast-1"
                    awslogs-stream-prefix = "backend"
                }
            }
        }
    ])

    tags = {
        Name = "${var.cluster_name}-task"
    }
}

# ECS Service
resource "aws_ecs_service" "main" {
    name            = "${var.cluster_name}-service"
    cluster         = aws_ecs_cluster.main.id
    task_definition = aws_ecs_task_definition.main.arn
    desired_count   = 2
    launch_type     = "FARGATE"

    network_configuration {
        subnets          = var.private_subnet_ids
        security_groups  = [var.security_group_id]
        assign_public_ip = false
    }

    load_balancer {
        target_group_arn = var.alb_target_group_arn
        container_name   = "backend"
        container_port   = 8080
    }

    tags = {
        Name = "${var.cluster_name}-service"
    }
}