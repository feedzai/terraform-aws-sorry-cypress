resource "aws_ecs_cluster" "sorry_cypress" {
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
  depends_on = [
    aws_cloudwatch_log_group.sorry_cypress_log_group
  ]
}

resource "aws_ecs_task_definition" "sorry_cypress" {
  family                   = "sorry-cypress"
  network_mode             = "awsvpc"
  memory                   = var.memory_request
  cpu                      = var.cpu_request
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
  requires_compatibilities = ["FARGATE"]
  container_definitions = templatefile(
    "${path.module}/container_definitions.json",
    {
      logs_group_name             = aws_cloudwatch_log_group.sorry_cypress_log_group.name
      region                      = "eu-west-1"
      dns_name                    = aws_route53_record.sorry_cypress.fqdn
      bucket_name                 = aws_s3_bucket.test_results_bucket.id
      docker_registry             = var.docker_registry
      docker_registry_credentials = var.docker_registry_credentials
    }
  )
  depends_on = [
    aws_ecs_cluster.sorry_cypress
  ]
}

resource "aws_ecs_service" "sorry_cypress_ecs_service" {
  name                               = "sorry-cypress-ecs-service"
  cluster                            = aws_ecs_cluster.sorry_cypress.arn
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 1
  health_check_grace_period_seconds  = 300

  network_configuration {
    security_groups  = [aws_security_group.sorry_cypress_fargate.id]
    subnets          = var.subnets.private
  }

  task_definition = aws_ecs_task_definition.sorry_cypress.arn

  load_balancer {
    container_name   = "api"
    container_port   = local.api_port
    target_group_arn = aws_lb_target_group.sorry_cypress_api.arn
  }
  load_balancer {
    container_name   = "director"
    container_port   = local.director_port
    target_group_arn = aws_lb_target_group.sorry_cypress_director.arn
  }
  load_balancer {
    container_name   = "dashboard"
    container_port   = local.dashboard_port
    target_group_arn = aws_lb_target_group.sorry_cypress_dashboard.arn
  }

  depends_on = [
    aws_ecs_cluster.sorry_cypress,
    aws_ecs_task_definition.sorry_cypress,
    aws_lb_target_group.sorry_cypress_api,
    aws_lb_target_group.sorry_cypress_director,
    aws_lb_target_group.sorry_cypress_dashboard
  ]
}
