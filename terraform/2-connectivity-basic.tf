# Internet Gateway for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  for_each = toset(var.availability_zones)

  domain = "vpc"

  tags = {
    Name = "nat-eip-${each.key}"
  }
}

# NAT Gateways in public egress subnets
resource "aws_nat_gateway" "nat" {
  for_each = toset(var.availability_zones)

  allocation_id = aws_eip.nat[each.key].id

  # We use egress subnet for NAT placement
  subnet_id = aws_subnet.egress[each.key].id

  tags = {
    Name = "nat-${each.key}"
  }

  depends_on = [aws_internet_gateway.igw]
}


# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Associate all public subnets to the public route table
resource "aws_route_table_association" "dmz" {
  for_each = aws_subnet.dmz

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "egress" {
  for_each = aws_subnet.egress

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}



# Private Route Tables per AZ with NAT
resource "aws_route_table" "private" {
  for_each = toset(var.availability_zones)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[each.key].id
  }

  tags = {
    Name = "private-rt-${each.key}"
  }
}

# Associate all private subnets to private route tables
resource "aws_route_table_association" "infra_eks_assoc" {
  for_each = aws_subnet.infra_eks

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "app_eks_assoc" {
  for_each = aws_subnet.app_eks

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
