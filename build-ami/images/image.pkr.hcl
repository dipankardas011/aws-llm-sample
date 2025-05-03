packer {
  required_plugins {
    amazon = {
      version = "~> 1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "g5.2xlarge"
}

variable "ebs_size" {
  type    = number
  default = 100
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }


source "amazon-ebs" "gg" {
  ami_name      = "qwen-instance-${local.timestamp}"
  instance_type = var.instance_type
  region        = var.region
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    encrypted = true
    volume_size = var.ebs_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "x86_64"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.gg"]

  provisioner "file" {
    source      = "../ssh_keys/key.pub"
    destination = "/tmp/tf-packer.pub"
  }
  provisioner "shell" {
    script = "../scripts/setup.sh"
  }
}
