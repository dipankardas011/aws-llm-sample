variable "workload_name" {
  description = "Name of the workload"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the ASG"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the instance"
  type        = string
}

variable "region" {
  description = "AWS region to deploy the ASG"
  type        = string
  default     = "us-east-1"
}

variable "subnet_ids" {
  description = "Subnet ID where the ASG will be deployed"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for the ASG instances"
  type        = string
}

variable "sg_max_instances" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 5
}

variable "model" {
  type = object({
    name = string
    port = number
  })
  description = "LLM Model configuration for the ASG instances"
}