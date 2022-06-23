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
|`zone_id`|A Route53 public zone ID|`string`||yes|
|`load_balancer`|A load balancer ARN|`string`||yes|
|`load_balancer_security_group`|A load balancer security group|`string`||yes|
|`load_balancer_listener`|A load balancer listener ARN|`string`||yes|
|`vcp_id`|A VPC ID|`string`||yes|
|`task_role_arn`|ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services|`string`||yes|
|`execution_role_arn`|ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume|`string`||yes|
|`cpu_request`|Number of CPU units used by the task|`string`|`1024`|no|
|`memory_request`|Amount (in MiB) of memory used by the task|`string`|`2048`|no|
|`subnets`|List of AWS subnets to deploy to|`list(string)`||yes|

## Outputs
|Name|Description|Example|
|----|-----------|-------|
|`api_url`|The SorryCypress API URL|`https://sorrycypress.example.com/api`|
|`dashboard_url`|The SorryCypress Dashboard URL|`https://sorrycypress.example.com`|
|`director_url`|The SorryCypress Director URL|`https://sorrycypress.example.com:1234`|

## Resources

|Name|Type|
|----|----|
|ad|resource|
|as|datasource|

## References

This modules was based on the [CloudFormation template](https://github.com/sorry-cypress/sorry-cypress/blob/master/cloudformation/sorry-cypress.yml) provided by SorryCypress