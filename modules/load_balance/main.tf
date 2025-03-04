# Create Application Load Balancer blue/green deployment
resource "aws_lb_target_group" "web_app_lb_tg_blue" {
  name     = "web-lb-tg-blue"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/"
    interval            = 20
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }  
  
  tags = {
    Name = "web_app_lb_tg_blue"
    }
}

resource "aws_lb_target_group" "web_app_lb_tg_green" {
  name     = "web-lb-tg-green"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path                = "/"
    interval            = 20
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }  
  
  tags = {
    Name = "web_app_lb_tg_green"
    }
}

# Use data sources to reference existing instances
data "aws_instance" "blue_instance" {
  instance_id = var.instance_id1
}

data "aws_instance" "green_instance" {
  instance_id = var.instance_id2
}

data "aws_security_group" "load_balance_security_group" {
  id = var.load_balance_security_group_ids
}

resource "aws_lb_target_group_attachment" "web_app_lb_tg_at_blue" {
    target_group_arn = aws_lb_target_group.web_app_lb_tg_blue.arn
    target_id        = data.aws_instance.blue_instance.id
    port             = 80
}

resource "aws_lb_target_group_attachment" "web_app_lb_tg_at_green" {
    target_group_arn = aws_lb_target_group.web_app_lb_tg_green.arn
    target_id        = data.aws_instance.green_instance.id
    port             = 80
}

resource "aws_lb" "web_app_lb" {
  name               = "web-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.load_balance_security_group.id]
  subnets            = var.load_balance_subnet_ids
  enable_cross_zone_load_balancing = true
  enable_deletion_protection = false
  
  tags = {
    Name = "web_app_lb"
    }
}

resource "aws_lb_listener" "web_app_lb_listener" {
  load_balancer_arn = aws_lb.web_app_lb.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_lb_tg_blue.arn
  }
}

# Define a variable to switch between Blue and Green deployments
variable "active_target_group" {
  description = "The active target group for the load balancer"
  type        = string
  default     = "green"
}

# ALB Listener Rules (One for Blue, One for Green)
resource "aws_lb_listener_rule" "web_app_lb_listener_blue" {
  listener_arn = aws_lb_listener.web_app_lb_listener.arn
  priority     = var.active_target_group == "blue" ? 1 : 100  # Higher priority when active

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_lb_tg_blue.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

resource "aws_lb_listener_rule" "web_app_lb_listener_green" {
  listener_arn = aws_lb_listener.web_app_lb_listener.arn
  priority     = var.active_target_group == "green" ? 1 : 100  # Higher priority when active

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_lb_tg_green.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}