
module "github_ssh_key" {
  source = "./modules/ssh_key"

  github_profile = "dipankardas011"
}

module "aws_network" {
  source = "./modules/network"

  workload_name = var.workload_name
  region        = var.aws_region
}

module "aws_security" {
  depends_on = [module.aws_network, module.github_ssh_key]
  source     = "./modules/security"

  workload_name  = var.workload_name
  region         = var.aws_region
  vpc_id         = module.aws_network.vpc_id
  ssh_key_public = module.github_ssh_key.public_ssh_key
}

module "aws_ami" {
  count  = length(var.custom_ami_id) > 0 ? 0 : 1
  source = "./modules/machine_image"
}

module "aws_vm" {
  depends_on = [module.aws_network, module.github_ssh_key, module.aws_security]
  source     = "./modules/vm-aws-ami"

  workload_name               = var.workload_name
  instance_type               = var.instance_type
  instance_count              = 1
  ami_id                      = length(var.custom_ami_id) > 0 ? var.custom_ami_id : module.aws_ami[0].ami_id
  custom_ami_contains_ssh_key = length(var.custom_ami_id) > 0 ? true : false # custom AMI when used will contain ssh key
  key_name                    = ""
  subnet_id                   = module.aws_network.private_subnet_id
  security_group_ids          = [module.aws_security.security_group_id]
  instance_category           = "on-demand"
  ebs_size                    = 100
}

output "instances_detail" {
  value = module.aws_vm.instance_details
}