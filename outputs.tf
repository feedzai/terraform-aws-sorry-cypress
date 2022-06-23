output "api_url" {
  value = "https://${aws_route53_record.sorry_cypress.fqdn}/api"
}

output "dashboard_url" {
  value = "https://${aws_route53_record.sorry_cypress.fqdn}"
}

output "director_url" {
    value = "https://${aws_route53_record.sorry_cypress.fqdn}:1234"
}
