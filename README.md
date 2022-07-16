# AWS Sorry Cypress Terraform Module

Terraform module that deploys Sorry Cypress on AWS.

## Usage

```hcl
module "sorry_cypress" {
    source = "terraform-aws-sorry-cypress"

    s3_bucket_name = "sorry_cypress_test_results"
    zone_id = "example.com"
    url = "sorrycypress.example.com"
    load_balancer_security_group = "sg-123456789"
    vpc_id = "vpc-123456"
    task_role_arn = "arn::iam::role"
    execution_role_arn = "arn::iam::role"
    subnets = {
        private = []
        public = []
    }
    alb_logs_bucket = "alb_logs_bucket"
    certificate_arn = "arn::acm::..."
    docker_registry_credentials = "secret-name-in-secrets-manager"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.12.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.12.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.sorry_cypress_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.sorry_cypress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.sorry_cypress_ecs_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.sorry_cypress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_lb.sorry_cypress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.dashboard_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.director_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.api_listener_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_listener_rule.https_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.sorry_cypress_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.sorry_cypress_dashboard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.sorry_cypress_director](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.sorry_cypress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.test_results_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.test_results_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.test_results_bucket_cors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.tests_retention_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.allow_access_from_prefix_list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.sorry_cypress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_security_group.sorry_cypress_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.sorry_cypress_fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_http_director](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_http_from_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_https_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_https_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_https_dashboard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_https_director](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_inbound_containers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_outbound_fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ec2_managed_prefix_list.prefix_list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_managed_prefix_list) | data source |
| [aws_iam_policy_document.allow_access_from_prefix_list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_logs_bucket"></a> [alb\_logs\_bucket](#input\_alb\_logs\_bucket) | An S3 bucket to store ALB access logs | `string` | n/a | yes |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | n/a | `string` | n/a | yes |
| <a name="input_cpu_request"></a> [cpu\_request](#input\_cpu\_request) | Number of cpu units used by the task | `string` | `"1024"` | no |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | The docker registry to pull sorry cypress images from | `string` | n/a | yes |
| <a name="input_docker_registry_credentials"></a> [docker\_registry\_credentials](#input\_docker\_registry\_credentials) | The ARN of the docker registry credentials secret in SecretsManager | `string` | n/a | yes |
| <a name="input_execution_role_arn"></a> [execution\_role\_arn](#input\_execution\_role\_arn) | ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume | `string` | n/a | yes |
| <a name="input_load_balancer_security_group"></a> [load\_balancer\_security\_group](#input\_load\_balancer\_security\_group) | The load balancer security group | <pre>object({<br>    id = string<br>  })</pre> | n/a | yes |
| <a name="input_memory_request"></a> [memory\_request](#input\_memory\_request) | Amount (in MiB) of memory used by the task | `string` | `"2048"` | no |
| <a name="input_prefix_list"></a> [prefix\_list](#input\_prefix\_list) | An EC2 managed prefix list | `string` | n/a | yes |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | S3 bucket name to store test results | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | AWS subnet IDs to deploy Sorry Cypress | <pre>object({<br>    private = list(string),<br>    public  = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn) | ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services | `string` | n/a | yes |
| <a name="input_test_results_retention"></a> [test\_results\_retention](#input\_test\_results\_retention) | The number of days to keep test results | `number` | `15` | no |
| <a name="input_url"></a> [url](#input\_url) | The URL to deploy SorryCypress to | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID | `string` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | The route53 zone id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_url"></a> [api\_url](#output\_api\_url) | The Sorry Cypress API endpoint |
| <a name="output_dashboard_url"></a> [dashboard\_url](#output\_dashboard\_url) | The Sorry Cypress dashboard URL |
| <a name="output_director_url"></a> [director\_url](#output\_director\_url) | The Sorry Cypress director URL |
| <a name="output_test_results_bucket"></a> [test\_results\_bucket](#output\_test\_results\_bucket) | The S3 bucket where test results are stored |
<!-- END_TF_DOCS -->

## References

This modules was based on the [CloudFormation template](https://github.com/sorry-cypress/sorry-cypress/blob/master/cloudformation/sorry-cypress.yml) provided by SorryCypress
