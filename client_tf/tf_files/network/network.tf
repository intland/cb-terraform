data "aws_availability_zones" "available" {}

locals {
  vpc_cidr_block="10.0.0.0/24"
  pub_cidrs = [
    "10.0.0.0/25",
    "10.0.0.128/25"
  ]
}

resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = merge(
    { Name        = "cb-vpc-${var.client_name}" },
    local.common_tags
  )
}

resource "aws_subnet" "main" {
  count = length(local.pub_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = local.pub_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    { Name        = "cb-subnet-${var.client_name}-${count.index}" },
    local.common_tags
  )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = merge(
    { Name        = "cb-igw-${var.client_name}" },
    local.common_tags
  )
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id  
  tags = merge(
    { Name        = "cb-vpc_rt-${var.client_name}" },
    local.common_tags
  )
}

resource "aws_route" "cb-to-internet" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id      = aws_internet_gateway.gw.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table_association" "main" {
  count = 2
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.main.id
}
