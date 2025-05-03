locals {
  tg_name = "${var.workload_name}-${var.region}-tg"
  lb_name = "${var.workload_name}-${var.region}-nlb"
}

resource "aws_lb_target_group" "lb-tg" {
  name             = local.tg_name
  port             = var.application_config.port
  protocol         = var.application_config.protocol
  vpc_id           = var.vpc_id
  protocol_version = "HTTP2"
  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 60
    protocol            = var.application_healthcheck_config.protocol
    port                = var.application_healthcheck_config.port
    path                = var.application_healthcheck_config.path
    unhealthy_threshold = 3
  }
}

resource "aws_autoscaling_attachment" "tg-asg" {
  autoscaling_group_name = var.asg_name
  lb_target_group_arn    = aws_lb_target_group.lb-tg.arn
}

resource "aws_lb" "test" {
  name               = local.lb_name
  internal           = true
  load_balancer_type = "network"
  subnets            = var.subnet_ids
  security_groups    = [var.lb_sg_id]

  enable_deletion_protection = true
}

output "lb_arn" {
  value = {
    arn      = aws_lb.test.arn
    dns_name = aws_lb.test.dns_name
    id       = aws_lb.test.id
  }
  description = "Load balancer details"
}