variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name to store test results"
}
variable "zone_id" {
  type        = string
  description = "The route53 zone id"
}
variable "url" {
  type        = string
  description = "The URL to deploy SorryCypress to"
}
variable "load_balancer_security_group" {
  type = object({
    id = string
  })
  description = "The load balancer security group"
}
variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}
variable "task_role_arn" {
  type        = string
  description = "ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services"
}
variable "execution_role_arn" {
  type        = string
  description = "ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume"
}
variable "cpu_request" {
  type        = string
  description = "Number of cpu units used by the task"
  default     = "1024"
}
variable "memory_request" {
  type        = string
  description = "Amount (in MiB) of memory used by the task"
  default     = "2048"
}
variable "subnets" {
  type = object({
    private = list(string),
    public  = list(string)
  })
  description = "AWS subnet IDs to deploy Sorry Cypress"
}
variable "alb_logs_bucket" {
  type        = string
  description = "An S3 bucket to store ALB access logs"
}
variable "certificate_arn" {
  type = string
}
variable "docker_registry" {
  type        = string
  description = "The docker registry to pull sorry cypress images from"
}
variable "docker_registry_credentials" {
  type        = string
  description = "The ARN of the docker registry credentials secret in SecretsManager"
}
variable "prefix_list" {
  type        = string
  description = "An EC2 managed prefix list"
}
variable "test_results_retention" {
  type        = number
  default     = 15
  description = "The number of days to keep test results"
}

variable "create_ecs_cluster" {
  default     = true
  type        = bool
  description = "boolean to define if ecs cluster should be created"
}

variable "ecs_cluster_arn" {
  default     = ""
  type        = string
  description = "define the complete ECS cluster ARN if already existing ecs cluster exists"
}
