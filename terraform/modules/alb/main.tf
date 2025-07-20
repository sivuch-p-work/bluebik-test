# Application Load Balancer
resource "aws_lb" "main" {
    name               = var.name
    internal           = false
    load_balancer_type = "application"
    security_groups    = [var.security_group_id]
    subnets            = var.public_subnet_ids

    enable_deletion_protection = false

    tags = {
        Name = var.name
    }
}

# Target Group for Backend (port 8080)
resource "aws_lb_target_group" "backend" {
    name        = "${var.name}-backend-tg"
    port        = 8080
    protocol    = "HTTP"
    vpc_id      = var.vpc_id
    target_type = "ip"

    health_check {
        enabled             = true
        healthy_threshold   = 2
        interval            = 30
        matcher             = "200"
        path                = "/healthz"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
    }

    tags = {
        Name = "${var.name}-backend-tg"
    }
}

# Target Group for Kong (port 8000)
resource "aws_lb_target_group" "kong" {
    name        = "${var.name}-kong-tg"
    port        = 8000
    protocol    = "HTTP"
    vpc_id      = var.vpc_id
    target_type = "ip"

    health_check {
        enabled             = true
        healthy_threshold   = 2
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
    }

    tags = {
        Name = "${var.name}-kong-tg"
    }
}

# ALB Listener
resource "aws_lb_listener" "main" {
    load_balancer_arn = aws_lb.main.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        type = "fixed-response"
        fixed_response {
            content_type = "text/plain"
            message_body = "No matching route found"
            status_code  = "404"
        }
    }
}

# Listener Rule for Backend API routes
resource "aws_lb_listener_rule" "backend" {
    listener_arn = aws_lb_listener.main.arn
    priority     = 100

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.backend.arn
    }

    condition {
        path_pattern {
            values = ["/api/*", "/test", "/db-check", "/redis-check", "/healthz"]
        }
    }
}

# Listener Rule for Kong (default traffic)
resource "aws_lb_listener_rule" "kong" {
    listener_arn = aws_lb_listener.main.arn
    priority     = 200

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.kong.arn
    }

    condition {
        path_pattern {
            values = ["/*"]  # catch-all pattern
        }
    }
} 