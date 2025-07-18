locals {
  azs = var.availability_zones

  subnet_groups = {
    infra_eks = var.subnet_cidrs.infra_eks
    app_eks   = var.subnet_cidrs.app_eks
    dmz       = var.subnet_cidrs.dmz
    egress    = var.subnet_cidrs.egress
  }
}

# VPC - Main
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# Private Subnets - Infrastructure EKS
resource "aws_subnet" "infra_eks" {
  for_each = zipmap(local.azs, local.subnet_groups.infra_eks)

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "infra-eks-${each.key}"
    "kubernetes.io/cluster/infra-eks" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }

  lifecycle {
    ignore_changes = [map_public_ip_on_launch]
  }
}

# Private Subnets - App EKS
resource "aws_subnet" "app_eks" {
  for_each = zipmap(local.azs, local.subnet_groups.app_eks)

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "app-eks-${each.key}"
  }
}

#Public Subnets - ELB/DMZ
resource "aws_subnet" "dmz" {
  for_each = zipmap(local.azs, local.subnet_groups.dmz)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "dmz-${each.key}"
  }
}

# Public Subnets - egress
resource "aws_subnet" "egress" {
  for_each = zipmap(local.azs, local.subnet_groups.egress)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "egress-${each.key}"
  }
}
