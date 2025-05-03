
locals {
  launch_template_name = "${var.workload_name}-${var.region}-asg-lt"
  asg_name             = "${var.workload_name}-${var.region}-asg"
}

resource "aws_launch_template" "launch_templ" {
  name = local.launch_template_name

  # NOTE: EBS Root volume is defined in the AMI creation itself

  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.security_group_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = local.launch_template_name
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  user_data = base64encode(templatefile("${path.module}/run_llm.tftpl", {
    model = var.model.name
    port  = var.model.port,
  }))
}

