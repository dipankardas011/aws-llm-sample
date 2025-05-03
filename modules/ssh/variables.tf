variable "workload_name" {
  type        = string
  description = "Name of the workload"
}

variable "region" {
  type        = string
  description = "AWS region to deploy the resources"
}

variable "ssh_key_public" {
  type        = string
  description = "Public SSH key for EC2 instances"
}
