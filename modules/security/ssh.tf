resource "aws_key_pair" "deployer" {
  key_name   = local.ssh_key_name
  public_key = var.ssh_key_public
}

output "ssh_key_name" {
  value = aws_key_pair.deployer.key_name
}