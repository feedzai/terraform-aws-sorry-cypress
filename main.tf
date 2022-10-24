locals {
  director_port  = 1234
  api_port       = 4000
  dashboard_port = 9090
  log_group_name = "/ecs/sorry-cypress"
}

resource "aws_cloudwatch_log_group" "sorry_cypress_log_group" {
  name              = local.log_group_name
  retention_in_days = 3
  tags              = var.tags
}

data "aws_canonical_user_id" "current" {}
