resource "aws_key_pair" "deployer" {
  key_name   = "${var.workload_name}-${var.region}-ssh-key"
  public_key = var.ssh_key_public
}

output "ssh_key_name" {
  value = aws_key_pair.deployer.key_name
}