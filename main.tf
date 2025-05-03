
module "github_ssh_key" {
  source = "./modules/ssh_key"

  github_profile = "dipankardas011"
}

module "aws_network" {
  source = "./modules/network"

  workload_name = var.workload_name
  region        = var.aws_region
}

module "aws_ssh" {
  count      = length(var.custom_ami_id) > 0 ? 0 : 1
  depends_on = [module.aws_network]
  source     = "./modules/ssh"

  workload_name  = var.workload_name
  region         = var.aws_region
  ssh_key_public = module.github_ssh_key.public_ssh_key
}

module "aws_firewall" {
  depends_on = [module.aws_network, module.github_ssh_key]
  source     = "./modules/firewall"

  workload_name = var.workload_name
  region        = var.aws_region
  vpc_id        = module.aws_network.vpc_id
}

module "aws_ami" {
  count  = length(var.custom_ami_id) > 0 ? 0 : 1
  source = "./modules/machine_image"
}

module "aws_vm" {
  count      = length(var.custom_ami_id) > 0 ? 0 : 1
  depends_on = [module.aws_network, module.github_ssh_key, module.aws_firewall]
  source     = "./modules/independent-vm"

  workload_name      = var.workload_name
  instance_type      = var.instance_type
  instance_count     = 1
  ami_id             = module.aws_ami[0].ami_id
  key_name           = module.github_ssh_key.public_ssh_key
  subnet_id          = module.aws_network.private_subnet_id
  security_group_ids = [module.aws_firewall.security_group_id]
  instance_category  = "on-demand"
  ebs_size           = 100
}

output "instances_detail" {
  value = length(module.aws_vm) > 0 ? module.aws_vm.instance_details : null
}

module "aws_asg_vm" {
  count      = length(var.custom_ami_id) > 0 ? 1 : 0
  depends_on = [module.aws_network, module.aws_firewall]
  source     = "./modules/asg-vm"

  sg_max_instances  = var.asg_max_instances
  workload_name     = var.workload_name
  instance_type     = var.instance_type
  ami_id            = var.custom_ami_id
  region            = var.aws_region
  subnet_ids        = [module.aws_network.private_subnet_id]
  security_group_id = module.aws_firewall.security_group_id
  model = {
    name = "Qwen/Qwen3-8B"
    port = 80
  }
}

output "asg_details" {
  value = length(module.aws_asg_vm) > 0 ? module.aws_asg_vm[0].asg_details : null
}

module "aws_lb_firewall" {
  count      = length(var.custom_ami_id) > 0 ? 1 : 0
  depends_on = [module.aws_network, module.aws_firewall]
  source     = "./modules/firewall"

  workload_name = "${var.workload_name}-lb"
  region        = var.aws_region
  vpc_id        = module.aws_network.vpc_id
  security_group_ingress_rules = [
    {
      port        = 443
      protocol    = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "access to the vms in the asg"
    },
  ]
}
output "lb_sg_id" {
  value = length(module.aws_lb_firewall) > 0 ? module.aws_lb_firewall[0].security_group_id : null
}

module "aws_lb" {
  count      = length(var.custom_ami_id) > 0 ? 1 : 0
  depends_on = [module.aws_network, module.aws_firewall]
  source     = "./modules/lb"

  workload_name = var.workload_name
  region        = var.aws_region
  vpc_id        = module.aws_network.vpc_id
  subnet_ids    = [module.aws_network.private_subnet_id]
  lb_sg_id      = module.aws_lb_firewall[0].security_group_id
  asg_name      = module.aws_asg_vm[0].asg_details.name
  application_config = {
    port     = 443
    protocol = "TCP"
  }
  application_healthcheck_config = {
    protocol = "TCP"
    port     = 443
    path     = ""
  }
}

output "lb_arn" {
  value = length(module.aws_lb) > 0 ? module.aws_lb[0].lb_arn : null
}


variable "vpc_endpointservice_alternate_dns_name" {
  description = "Alternate DNS name for the PrivateLink endpoint for consumer to use"
  type        = string
  default     = ""
}

module "aws_privatelink" {
  count      = length(var.custom_ami_id) > 0 ? 1 : 0
  depends_on = [module.aws_network, module.aws_firewall]
  source     = "./modules/vpc_es"

  workload_name      = var.workload_name
  region             = var.aws_region
  vpc_id             = module.aws_network.vpc_id
  alternate_dns_name = var.vpc_endpointservice_alternate_dns_name
  nlb_arn            = module.aws_lb[0].lb_arn.arn
  supported_regions  = [var.aws_region]
}

output "vpc_endpointservice" {
  value = length(module.aws_privatelink) > 0 ? module.aws_privatelink[0].aws_privatelink : null
}