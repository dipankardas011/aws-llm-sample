variable "vpc_id" {
  description = "VPC ID where the resources will be deployed"
  type        = string
}

variable "region" {
  description = "AWS region to deploy the resources"
  type        = string
}

variable "workload_name" {
  description = "Name of the workload"
  type        = string
}

variable "nlb_arn" {
  description = "ARN of the Network Load Balancer"
  type        = string
}

variable "supported_regions" {
  description = "List of supported regions for the VPC endpoint service"
  type        = list(string)
}

variable "alternate_dns_name" {
  description = "Private DNS name for the VPC endpoint service"
  type        = string
}

variable "default_allowed_principles" {
  description = "List of default allowed principles for the VPC endpoint service"
  type        = set(string)
  default     = []
}

resource "aws_vpc_endpoint_service" "vpces" {
  acceptance_required        = true
  network_load_balancer_arns = [var.nlb_arn]
  supported_regions          = var.supported_regions
  private_dns_name           = var.alternate_dns_name
  allowed_principals         = var.default_allowed_principles
  tags = {
    Name = "${var.workload_name}-${var.region}-vpc-endpoint-service"
  }
}

output "aws_privatelink" {
  value = {
    service_id                 = aws_vpc_endpoint_service.vpces.id
    arn                        = aws_vpc_endpoint_service.vpces.arn
    consumer_dns_name          = aws_vpc_endpoint_service.vpces.base_endpoint_dns_names
    alternate_dns_name_configs = aws_vpc_endpoint_service.vpces.private_dns_name_configuration
    service_name               = aws_vpc_endpoint_service.vpces.service_name
  }
  description = "AWS PrivateLink details"
}
