# AWS Sorry Cypress Terraform Module

Terraform module that deploys Sorry Cypress on AWS.

## Usage

```hcl
module "sorry_cypress" {
    source = "terraform-aws-sorry-cypress"

    zone_id = "example.com"
    load_balancer_arn = "arn::"
    load_balancer_security_group = "sg-123"
    load_balancer_listener_arn = "arn::"
    vpc_id = "vpc-123"
    subents_ids = [ "subnet-123", "subnet-456" ]
    task_role_arn = "arn::role"
    execution_role_arn = "arn::role"
}
```

## Requirements
|Name|Version|
|----|-------|
|terraform|>=1.2.3|
|aws|>=3.0|

## Providers
|Name|Version|
|----|-------|
|aws|>=3.0|

## Inputs

|Name|Description|Type|Default|Required|
|----|-----------|----|-------|--------|
|`s3_bucket_name`|S3 bucket name to store test results|`string`|yes|
|`zone_id`|A Route53 public zone ID|`string`|yes|
|`url`|The URL to deploy SorryCypress to|`string`|yes|
|`load_balancer`|The load balancer resource|`string`|yes|
|`load_balancer_security_group`|The load balancer security group ID|`string`|yes|
|`load_balancer_listener`|The load balancer HTTPS listener ARN|`string`|yes|
|`vpc_id`|The VPC ID|`string`|yes|
|`task_role_arn`|ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services|`string`|yes|
|`execution_role_arn`|ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume|`string`|yes|
|`cpu_request`|Number of cpu units used by the task|`string`|no|
|`memory_request`|Amount (in MiB) of memory used by the task|`string`|no|
|`subnets`|AWS subnet IDs to deploy Sorry Cypress|`string`|yes|

## Outputs
|Name|Description|Example|
|----|-----------|-------|
|`api_url`|The SorryCypress API URL|`https://sorrycypress.example.com/api`|
|`dashboard_url`|The SorryCypress Dashboard URL|`https://sorrycypress.example.com`|
|`director_url`|The SorryCypress Director URL|`https://sorrycypress.example.com:1234`|

## Resources

|Name|Type|
|----|----|
|`aws_s3_bucket.test_results_bucket`| resource |
|`aws_s3_bucket_acl.test_results_acl`| resource |
|`aws_s3_bucket_cors_configuration.test_results_bucket_cors`| resource |
|`aws_s3_bucket_public_access_block.sorry_cypress`| resource |
|`aws_s3_bucket_server_side_encryption_configuration.sorry_cypress`| resource |
|`aws_security_group.sorry_cypress_security_group`| resource |
|`aws_security_group_rule.ingress_public_alb`| resource |
|`aws_security_group_rule.ingress_containers_same_sg`| resource |
|`aws_route53_record.sorry_cypress`| resource |
|`aws_lb_target_group.sorry_cypress_director`| resource |
|`aws_lb_target_group.sorry_cypress_api`| resource |
|`aws_lb_target_group.sorry_cypress_dashboard`| resource |
|`aws_lb_listener_rule.api_listener_rule`| resource |
|`aws_cloudwatch_log_group.sorry_cypress_log_group`| resource |
|`aws_ecs_cluster.sorry_cypress_ecs_cluster`| resource |
|`aws_ecs_task_definition.sorry_cypress`| resource |
|`aws_ecs_service.sorry_cypress_ecs_service`| resource |

## References

This modules was based on the [CloudFormation template](https://github.com/sorry-cypress/sorry-cypress/blob/master/cloudformation/sorry-cypress.yml) provided by SorryCypress