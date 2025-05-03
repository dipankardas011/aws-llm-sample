terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0.0"
}

data "aws_ami" "ubuntu_latest" {
  most_recent = true

  # Refer: https://ubuntu.com/tutorials/search-and-launch-ubuntu-22-04-in-aws-using-cli#2-search-for-the-right-ami
  owners = ["099720109477"] # Canonical's id

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

output "ami_id" {
  value = data.aws_ami.ubuntu_latest.id
}