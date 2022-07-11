resource "aws_route53_record" "sorry_cypress" {
  zone_id = var.zone_id
  name    = var.url
  type    = "A"
  alias {
    name                   = aws_lb.sorry_cypress.dns_name
    zone_id                = aws_lb.sorry_cypress.zone_id
    evaluate_target_health = true
  }
}

resource "aws_security_group" "sorry_cypress_alb" {
  name        = "SorryCypressALBSecurityGroup"
  description = "Security Group for the Sorry Cypress ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name = "SorryCypress ALB Security Group"
  }
}
resource "aws_security_group_rule" "allow_http_alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.sorry_cypress_alb.id
  prefix_list_ids   = [var.prefix_list]
  description       = "Allow HTTP traffic from Feedzai"
}
resource "aws_security_group_rule" "allow_https_alb" {
  type            = "ingress"
  description     = "Allow HTTPS traffic from Feedzai"
  from_port       = 443
  to_port         = 443
  protocol        = "tcp"
  prefix_list_ids = [var.prefix_list]

  security_group_id = aws_security_group.sorry_cypress_alb.id
}
resource "aws_security_group_rule" "allow_https_dashboard" {
  type              = "ingress"
  description       = "Allow HTTPS traffic for Dashboard"
  from_port         = local.dashboard_port
  to_port           = local.dashboard_port
  protocol          = "tcp"
  security_group_id = aws_security_group.sorry_cypress_alb.id

  source_security_group_id = aws_security_group.sorry_cypress_fargate.id
}
resource "aws_security_group_rule" "allow_https_director" {
  type              = "ingress"
  description       = "Allow HTTPS traffic for Director"
  from_port         = local.director_port
  to_port           = local.director_port
  protocol          = "tcp"
  security_group_id = aws_security_group.sorry_cypress_alb.id

  source_security_group_id = aws_security_group.sorry_cypress_fargate.id
}
resource "aws_security_group_rule" "allow_https_api" {
  type              = "ingress"
  description       = "Allow HTTPS traffic for API"
  from_port         = local.api_port
  to_port           = local.api_port
  protocol          = "tcp"
  security_group_id = aws_security_group.sorry_cypress_alb.id

  source_security_group_id = aws_security_group.sorry_cypress_fargate.id
}
resource "aws_security_group_rule" "allow_outbound" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sorry_cypress_alb.id

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "sorry_cypress_fargate" {
  name        = "SorryCypressFargateSecurityGroup"
  description = "Access to the sorry cypress Fargate containers"
  vpc_id      = var.vpc_id

  tags = {
    Name = "SorryCypress Fargate Security Group"
  }
  depends_on = [
    aws_security_group.sorry_cypress_alb
  ]
}
resource "aws_security_group_rule" "allow_inbound_containers" {
  type              = "ingress"
  description       = "Allow traffic from other containers"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sorry_cypress_fargate.id
  self              = true
}
resource "aws_security_group_rule" "allow_http_from_alb" {
  type              = "ingress"
  description       = "Allow HTTP traffic from SorryCypress ALB"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  security_group_id = aws_security_group.sorry_cypress_fargate.id

  source_security_group_id = aws_security_group.sorry_cypress_alb.id
}
resource "aws_security_group_rule" "allow_outbound_fargate" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sorry_cypress_fargate.id

  cidr_blocks = [
    "0.0.0.0/0"
  ]
}

### Target Groups
resource "aws_lb_target_group" "sorry_cypress_director" {
  name        = "sorry-cypress-director"
  protocol    = "HTTP"
  port        = local.director_port
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 10
    matcher             = "200"
    path                = "/ping"
  }
}

resource "aws_lb_target_group" "sorry_cypress_api" {
  name        = "sorry-cypress-api"
  protocol    = "HTTP"
  port        = local.api_port
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 10
    matcher             = "200"
    path                = "/.well-known/apollo/server-health"

  }
}

resource "aws_lb_target_group" "sorry_cypress_dashboard" {
  name        = "sorry-cypress-dashboard"
  protocol    = "HTTP"
  port        = local.dashboard_port
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 10
    matcher             = "200"
    path                = "/"

  }
}
### Target Groups ####

# Application Load Balancer
resource "aws_lb" "sorry_cypress" {
  name               = "sorry-cypress-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sorry_cypress_alb.id, aws_security_group.sorry_cypress_fargate.id]
  subnets            = var.subnets.public

  access_logs {
    bucket  = var.alb_logs_bucket
    prefix  = "sorry-cypress"
    enabled = true
  }

  depends_on = [
    aws_security_group.sorry_cypress_alb,
    aws_security_group.sorry_cypress_fargate
  ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.sorry_cypress.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
      host        = "#{host}"
      path        = "/#{path}"
      query       = "#{query}"
    }
  }
  depends_on = [
    aws_lb.sorry_cypress
  ]
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.sorry_cypress.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = var.certificate_arn
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.sorry_cypress_dashboard.arn
  }
  depends_on = [
    aws_lb.sorry_cypress
  ]
}

resource "aws_lb_listener_rule" "https_api" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sorry_cypress_api.arn
  }
  condition {
    path_pattern {
      values = [
        "/api"
      ]
    }
  }
  depends_on = [
    aws_lb_listener.https,
    aws_lb_target_group.sorry_cypress_api
  ]
}

resource "aws_lb_listener" "director_listener" {
  load_balancer_arn = aws_lb.sorry_cypress.arn
  port              = local.director_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sorry_cypress_director.arn
  }

  depends_on = [
    aws_lb.sorry_cypress,
    aws_lb_target_group.sorry_cypress_director
  ]
}

resource "aws_lb_listener" "dashboard_listener" {
  load_balancer_arn = aws_lb.sorry_cypress.arn
  port              = local.dashboard_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sorry_cypress_dashboard.arn
  }

  depends_on = [
    aws_lb.sorry_cypress,
    aws_lb_target_group.sorry_cypress_dashboard
  ]
}

resource "aws_lb_listener_rule" "api_listener_rule" {
  listener_arn = aws_lb_listener.dashboard_listener.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sorry_cypress_api.arn
  }
  condition {
    path_pattern {
      values = [
        "/api"
      ]
    }
  }
  depends_on = [
    aws_lb_listener.dashboard_listener,
    aws_lb_target_group.sorry_cypress_api
  ]
}
