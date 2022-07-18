locals {
  director_port  = 1234
  api_port       = 4000
  dashboard_port = 8080
}

resource "aws_cloudwatch_log_group" "sorry_cypress_log_group" {
  name              = "/ecs/sorry-cypress"
  retention_in_days = 14
}

data "aws_canonical_user_id" "current" {}
