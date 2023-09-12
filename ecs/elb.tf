########################################
# ALB
########################################
resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.web_sg.id
  ]
  subnets = [
    aws_subnet.public_subnet_1a.id,
    aws_subnet.public_subnet_1c.id
  ]
}

########################################
# ALB Listener
########################################
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  protocol          = "HTTP"
  port              = 80

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp.arn
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}

########################################
# ALB Target Group
########################################
resource "aws_lb_target_group" "webapp" {
  name        = "webapp-blue-tg"
  vpc_id      = aws_vpc.vpc.id
  protocol    = "HTTP"
  port        = 3000
  target_type = "ip"

  health_check {
    port = 3000
    path = "/"
  }
}
