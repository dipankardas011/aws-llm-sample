variable "workload_name" {
  type        = string
  description = "Name of the workload"
}

variable "region" {
  type        = string
  description = "AWS region to deploy the resources"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnets_cidr" {
  type        = map(string)
  description = "CIDR block for the subnet"
  default = {
    "public"  = cidrsubnet(var.vpc_cidr, 1, 0)
    "private" = cidrsubnet(var.vpc_cidr, 1, 1)
  }
}