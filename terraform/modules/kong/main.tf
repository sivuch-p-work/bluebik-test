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

# IAM Policy for Secrets Manager access
resource "aws_iam_policy" "secrets_access" {
    name        = "${var.cluster_name}-secrets-access"
    description = "Allow ECS tasks to access Secrets Manager"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "secretsmanager:GetSecretValue"
                ]
                Resource = var.secrets_arn
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "secrets_access" {
    role       = aws_iam_role.ecs_execution_role.name
    policy_arn = aws_iam_policy.secrets_access.arn
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
    cpu                      = 256
    memory                   = 512
    execution_role_arn       = aws_iam_role.ecs_execution_role.arn
    task_role_arn            = aws_iam_role.ecs_task_role.arn

    container_definitions = jsonencode([
        {
            name  = "kong"
            image = var.image_url
            command = ["/bin/sh", "-c", "kong migrations bootstrap && kong start"]
            
            portMappings = [
                {
                    containerPort = 8000
                    protocol      = "tcp"
                },
                {
                    containerPort = 8001
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
                    name  = "KONG_PG_PORT"
                    value = "5432"
                },
                {
                    name  = "KONG_PG_DATABASE"
                    value = var.kong_db_name
                },
                {
                    name  = "KONG_PG_SSL"
                    value = "on"
                },
                {
                    name  = "KONG_PROXY_LISTEN"
                    value = "0.0.0.0:8000"
                },
                {
                    name  = "KONG_ADMIN_LISTEN"
                    value = "0.0.0.0:8001"
                },
                {
                    name  = "KONG_PROXY_ACCESS_LOG"
                    value = "/dev/stdout"
                },
                {
                    name  = "KONG_ADMIN_ACCESS_LOG"
                    value = "/dev/stdout"
                },
                {
                    name  = "KONG_PROXY_ERROR_LOG"
                    value = "/dev/stderr"
                },
                {
                    name  = "KONG_ADMIN_ERROR_LOG"
                    value = "/dev/stderr"
                }
            ]

            secrets = [
                {
                    name      = "KONG_PG_USER"
                    valueFrom = "${var.secrets_arn}:KONG_USER::"
                },
                {
                    name      = "KONG_PG_PASSWORD"
                    valueFrom = "${var.secrets_arn}:KONG_PASSWORD::"
                }
            ]

            logConfiguration = {
                logDriver = "awslogs"
                options = {
                    awslogs-group         = aws_cloudwatch_log_group.main.name
                    awslogs-region        = "ap-southeast-1"
                    awslogs-stream-prefix = "kong"
                }
            }
        },
        {
            name = "healthcheck",
            image = "curlimages/curl:latest",
            entryPoint = ["sh", "-c"],
            command = [
                "while true; do curl -f http://localhost:8001/status || echo fail; sleep 10; done"
            ],
            dependsOn = [
                { "containerName": "kong", "condition": "START" }
            ]
        }
    ])

    tags = {
        Name = "${var.cluster_name}-task"
    }
}

# ECS Service
resource "aws_ecs_service" "main" {
    name                    = "${var.cluster_name}-service"
    cluster                 = aws_ecs_cluster.main.id
    task_definition         = aws_ecs_task_definition.main.arn
    desired_count           = 2
    launch_type             = "FARGATE"
    enable_execute_command  = true

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

    tags = {
        Name = "${var.cluster_name}-service"
    }
}

# resource "null_resource" "kong_health_route" {
#     depends_on = [aws_ecs_service.main]

#     provisioner "local-exec" {
#         command = <<EOT
#             sleep 60

#             curl -s -X POST http://localhost:8001/services \
#                 --data 'name=kong-health' \
#                 --data 'url=http://localhost:8001/status' || true

#             curl -s -X POST http://localhost:8001/services/kong-health/routes \
#                 --data 'name=kong-health-route' \
#                 --data 'paths[]=/healthz' || true
#             EOT
#     }
# }