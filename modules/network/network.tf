terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0.0"
}

locals {
  vpc_name                 = "${var.workload_name}-${var.region}-vpc"
  public_subnet_name       = "${var.workload_name}-${var.region}-public"
  private_subnet_name      = "${var.workload_name}-${var.region}-private"
  internet_gateway_name    = "${var.workload_name}-${var.region}-igw"
  public_route_table_name  = "${var.workload_name}-${var.region}-public-rt"
  private_route_table_name = "${var.workload_name}-${var.region}-private-rt"
  nat_gateway_name         = "${var.workload_name}-${var.region}-nat"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = local.vpc_name
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnets_cidr["public"]
  tags = {
    Name = local.public_subnet_name
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnets_cidr["private"]
  tags = {
    Name = local.private_subnet_name
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = local.internet_gateway_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = local.public_route_table_name
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_route_table" "private" {
  depends_on = [aws_eip.nat]
  vpc_id     = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = local.private_route_table_name
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name : local.nat_gateway_name
  }
}


output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the VPC"
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "ID of the public subnet"
}

output "private_subnet_id" {
  value       = aws_subnet.private.id
  description = "ID of the private subnet"
}
