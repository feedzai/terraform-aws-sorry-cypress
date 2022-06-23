  resource "aws_s3_bucket" "test_results_bucket" {
    bucket = var.s3_bucket_name
  }

  resource "aws_s3_bucket_acl" "test_results_acl" {
    bucket = aws_s3_bucket.test_results_bucket.id
    acl    = "private"
  }

  resource "aws_s3_bucket_cors_configuration" "test_results_bucket_cors" {
    bucket = aws_s3_bucket.test_results_bucket.bucket

    cors_rule {
      allowed_headers = ["*"]
      allowed_methods = [
        "POST", "GET", "PUT", "DELETE", "HEAD"
      ]
      allowed_origins = ["*"]
    }
  }

  resource "aws_s3_bucket_public_access_block" "sorry_cypress" {
    bucket = aws_s3_bucket.test_results_bucket.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
  }

  resource "aws_s3_bucket_server_side_encryption_configuration" "sorry_cypress" {
    bucket = aws_s3_bucket.test_results_bucket.bucket
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
      bucket_key_enabled = true
    }
  }

  resource "aws_security_group" "sorry_cypress_security_group" {
    name        = "SorryCypressSecurityGroup"
    description = "Access to the sorry cypress Fargate containers"
    vpc_id      = var.vpc_id

    ingress {
      description = "Ingress from public ALB"
      protocol    = -1
      from_port   = 0
      to_port     = 0
      security_groups = [
        var.load_balancer_security_group.id
      ]
    }

  }

  resource "aws_security_group_rule" "ingress_public_alb" {
    type                     = "ingress"
    description              = "Ingress from public ALB"
    protocol                 = -1
    from_port                = 0
    to_port                  = 0
    security_group_id        = aws_security_group.sorry_cypress_security_group.id
    source_security_group_id = var.load_balancer_security_group.id
  }

  resource "aws_security_group_rule" "ingress_containers_same_sg" {
    description       = "Ingress from other containers in the same security group"
    type              = "ingress"
    protocol          = -1
    from_port         = 0
    to_port           = 0
    security_group_id = aws_security_group.sorry_cypress_security_group.id
    self              = true
  }

  resource "aws_route53_record" "sorry_cypress" {
    zone_id = var.zone_id
    name    = var.url
    type    = "A"
    alias {
      name                   = var.load_balancer.dns_name
      zone_id                = var.load_balancer.zone_id
      evaluate_target_health = true
    }
  }

  resource "aws_lb_target_group" "sorry_cypress_director" {
    name        = "sorry-cypress-director"
    protocol    = "HTTP"
    port        = 1234
    vpc_id      = var.vpc_id
    target_type = "ip"

    health_check {
      interval            = 15
      healthy_threshold   = 2
      unhealthy_threshold = 2
      matcher             = "200"
      path                = "/ping"
      timeout             = 5

    }
  }

  resource "aws_lb_target_group" "sorry_cypress_api" {
    name        = "sorry-cypress-api"
    protocol    = "HTTP"
    port        = 4000
    vpc_id      = var.vpc_id
    target_type = "ip"

    health_check {
      interval            = 15
      healthy_threshold   = 2
      unhealthy_threshold = 2
      matcher             = "200"
      path                = "/.well-known/apollo/server-health"
      timeout             = 5

    }
  }

  resource "aws_lb_target_group" "sorry_cypress_dashboard" {
    name        = "sorry-cypress-dashboard"
    protocol    = "HTTP"
    port        = 8080
    vpc_id      = var.vpc_id
    target_type = "ip"

    health_check {
      interval            = 15
      healthy_threshold   = 2
      unhealthy_threshold = 2
      matcher             = "200"
      path                = "/"
      timeout             = 5

    }
  }

  resource "aws_lb_listener_rule" "api_listener_rule" {
    listener_arn = var.load_balancer_listener.arn

    action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.sorry_cypress_api.arn
    }

    condition {
      path_pattern {
        values = ["/api"]
      }
    }
    condition {
      host_header {
        values = [
          aws_route53_record.sorry_cypress.fqdn
        ]
      }
    }
  }

  resource "aws_cloudwatch_log_group" "sorry_cypress_log_group" {
    name              = "/ecs/sorry-cypress"
    retention_in_days = 14
  }

  resource "aws_ecs_cluster" "sorry_cypress_ecs_cluster" {
    name = "sorry-cypress-ecs-cluster"
    configuration {
      execute_command_configuration {
        logging = "OVERRIDE"
        log_configuration {
          cloud_watch_encryption_enabled = true
          cloud_watch_log_group_name     = aws_cloudwatch_log_group.sorry_cypress_log_group.name
        }
      }
    }
  }

  resource "aws_ecs_task_definition" "sorry_cypress" {
    family                   = "sorry-cypress"
    network_mode             = "awsvpc"
    memory                   = var.memory_request
    cpu                      = var.cpu_request
    task_role_arn            = var.task_role_arn
    execution_role_arn       = var.execution_role_arn
    requires_compatibilities = ["FARGATE"]
    container_definitions = jsonencode([
      {
        name      = "api"
        image     = "nginx:alpine"
        essential = true
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "${aws_cloudwatch_log_group.sorry_cypress_log_group.arn}"
            awslogs-region        = "eu-west-1"
            awslogs-stream-prefix = "ecs"
          }
        }
        environment = [
          {
            name  = "MONGODB_DATABASE"
            value = "sorry-cypress"
          },
          {
            name  = "MONGODB_URI"
            value = "mongodb://sorry-cypress:sorry-cypress@127.0.0.1:27017"
          }
        ]
      }
    ])
  }

  resource "aws_ecs_service" "sorry_cypress_ecs_service" {
    name                               = "sorry-cypress-ecs-service"
    cluster                            = aws_ecs_cluster.sorry_cypress_ecs_cluster.arn
    launch_type                        = "FARGATE"
    deployment_maximum_percent         = 200
    deployment_minimum_healthy_percent = 100
    desired_count                      = 1
    network_configuration {
      security_groups = [
        aws_security_group.sorry_cypress_security_group.id
      ]
      subnets = toset(var.subnets)
    }
    task_definition = aws_ecs_task_definition.sorry_cypress.arn

    load_balancer {
      container_name   = "api"
      target_group_arn = aws_lb_target_group.sorry_cypress_api.arn
      container_port   = 80
    }
    load_balancer {
      container_name   = "director"
      target_group_arn = aws_lb_target_group.sorry_cypress_director.arn
      container_port   = 1234
    }
    load_balancer {
      container_name   = "dashboard"
      target_group_arn = aws_lb_target_group.sorry_cypress_dashboard.arn
      container_port   = 8080
    }
  }
