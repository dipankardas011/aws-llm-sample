variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "g5.xlarge"
}

variable "workload_name" {
  default = "qwen-vllm"
  type    = string
}

variable "custom_ami_id" {
  type    = string
  default = "ami-03de89ae8f497f89e"
}

variable "asg_max_instances" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 1
}