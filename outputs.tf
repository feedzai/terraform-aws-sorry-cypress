output "api_url" {
  value = "https://${aws_route53_record.sorry_cypress.fqdn}/api"
  description = "The Sorry Cypress API endpoint"
}

output "dashboard_url" {
  value = "https://${aws_route53_record.sorry_cypress.fqdn}"
  description = "The Sorry Cypress dashboard URL"
}

output "director_url" {
  value = "https://${aws_route53_record.sorry_cypress.fqdn}:1234"
  description = "The Sorry Cypress director URL"
}

output "test_results_bucket" {
  value = aws_s3_bucket.test_results_bucket
  description = "The S3 bucket where test results are stored"
}
