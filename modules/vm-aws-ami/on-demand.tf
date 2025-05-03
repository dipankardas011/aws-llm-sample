
resource "aws_instance" "ubuntu_server" {
  count = var.instance_category == "on-demand" ? var.instance_count : 0

  ami                    = var.ami_id
  instance_type          = var.instance_type

  dynamic "key_name" {
    for_each = var.custom_ami_contains_ssh_key ? [] : [1]
    content {
      key_name = var.key_name
    }
  }
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids

  tags = {
    Name = "on-demand-${var.workload_name}-${count.index}"
  }

  # Require IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # This enforces IMDSv2
  }

  root_block_device {
    volume_size           = var.ebs_size
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  user_data = var.user_data
}