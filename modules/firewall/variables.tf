variable "workload_name" {
  type        = string
  description = "Name of the workload"
}

variable "region" {
  type        = string
  description = "AWS region to deploy the resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the security group will be created"
}


variable "security_group_ingress_rules" {
  type = list(object({
    port        = number
    protocol    = string
    cidr_ipv4   = string
    description = string
  }))

  default = [
    {
      port        = 22
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "SSH access"
    },
    {
      port        = 443
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "HTTPS access"
    },
    {
      port        = 80
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "HTTP access"
    }
  ]
}
