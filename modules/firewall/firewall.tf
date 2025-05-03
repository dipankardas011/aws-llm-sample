locals {
  instance_firewall_name = "${var.workload_name}-${var.region}-fw"
}

resource "aws_security_group" "allow_traffic" {
  name        = local.instance_firewall_name
  description = "Allowed traffic to the instance"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each          = { for rule in var.security_group_ingress_rules : "${rule.port}-${rule.protocol}" => rule }
  security_group_id = aws_security_group.allow_traffic.id

  cidr_ipv4   = each.value.cidr_ipv4
  from_port   = each.value.port
  ip_protocol = each.value.protocol
  to_port     = each.value.port
  description = each.value.description
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.allow_traffic.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

output "security_group_id" {
  value = aws_security_group.allow_traffic.id
}
