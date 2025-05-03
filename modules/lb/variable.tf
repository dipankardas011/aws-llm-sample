variable "vpc_id" {
  description = "VPC ID where the ASG will be deployed"
  type        = string
}

variable "workload_name" {
  description = "Name of the workload"
  type        = string
}

variable "region" {
  description = "AWS region to deploy the resources"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the load balancer"
  type        = list(string)
}

variable "lb_sg_id" {
  description = "Security group ID for the load balancer"
  type        = string
}

variable "asg_name" {
  description = "Auto Scaling Group Name"
  type        = string
}

variable "application_config" {
  type = object({
    port     = number
    protocol = string
  })

  description = "Application configuration for the target group"
}

variable "application_healthcheck_config" {
  type = object({
    protocol = string
    port     = number
    path     = string
  })

  description = "Application liveliness configuration for the target group"
}