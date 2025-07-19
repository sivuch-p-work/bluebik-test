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

# Target Group
resource "aws_lb_target_group" "main" {
    name        = "${var.name}-tg"
    port        = 80
    protocol    = "HTTP"
    vpc_id      = var.vpc_id
    target_type = "ip"

    # health_check {
    #     enabled             = true
    #     healthy_threshold   = 2
    #     interval            = 30
    #     matcher             = "200"
    #     path                = "/health"
    #     port                = "traffic-port"
    #     protocol            = "HTTP"
    #     timeout             = 5
    #     unhealthy_threshold = 2
    # }

    tags = {
        Name = "${var.name}-tg"
    }
}

# ALB Listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
} 