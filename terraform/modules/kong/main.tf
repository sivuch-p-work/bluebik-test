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
    cpu                      = 256
    memory                   = 512
    execution_role_arn       = aws_iam_role.ecs_execution_role.arn
    task_role_arn            = aws_iam_role.ecs_task_role.arn

    container_definitions = jsonencode([
        {
            name  = "kong"
            image = "kong:latest"
            
            portMappings = [
                {
                    containerPort = 8000
                    protocol      = "tcp"
                },
                {
                    containerPort = 8443
                    protocol      = "tcp"
                }
            ]

            environment = [
                {
                    name  = "KONG_DATABASE"
                    value = "postgres"
                },
                {
                    name  = "KONG_PG_HOST"
                    value = var.kong_db_host
                },
                {
                    name  = "KONG_PG_USER"
                    value = var.kong_db_user
                },
                {
                    name  = "KONG_ADMIN_LISTEN"
                    value = "0.0.0.0:8001"
                },
                {
                    name  = "KONG_ADMIN_GUI_URL"
                    value = "http://localhost:8002"
                }
                # {
                #     name  = "KONG_PG_PASSWORD"
                #     value = var.kong_db_password
                # },
                # {
                #     name  = "KONG_PROXY_ACCESS_LOG"
                #     value = "/dev/stdout"
                # },
                # {
                #     name  = "KONG_ADMIN_ACCESS_LOG"
                #     value = "/dev/stdout"
                # },
                # {
                #     name  = "KONG_PROXY_ERROR_LOG"
                #     value = "/dev/stderr"
                # },
                # {
                #     name  = "KONG_ADMIN_ERROR_LOG"
                #     value = "/dev/stderr"
                # }
            ]

            # logConfiguration = {
            #     logDriver = "awslogs"
            #     options = {
            #         awslogs-group         = aws_cloudwatch_log_group.main.name
            #         awslogs-region        = "ap-southeast-1"
            #         awslogs-stream-prefix = "kong"
            #     }
            # }
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
        container_name   = "kong"
        container_port   = 8000
    }

    depends_on = []

    tags = {
        Name = "${var.cluster_name}-service"
    }
}

# CloudWatch Log Group
# resource "aws_cloudwatch_log_group" "main" {
#     name              = "/ecs/${var.cluster_name}"
#     retention_in_days = 7

#     tags = {
#         Name = "${var.cluster_name}-logs"
#     }
# }