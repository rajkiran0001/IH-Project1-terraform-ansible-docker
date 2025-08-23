
# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}
# --- Internet Gateway for Public Subnet ---
resource "aws_internet_gateway" "gw" {
  vpc_id = var.vpc_id
}
# --- Public Subnet ---
resource "aws_subnet" "public" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"
  tags = {
    Name = "public-subnet"
  }
}
# --- Route Table Public ---
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = var.public_subnet_id
  route_table_id = var.route_table_public_id
}

# --- Private Subnet ---
resource "aws_subnet" "private" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-1b"
  tags = { Name = "private-subnet" }
}

# Private route table (no NAT, only local traffic)
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id
}

# Associate the private subnet with its route table
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = var.private_subnet_id
  route_table_id = var.route_table_private_id
}

# --- Elastic IP for NAT Gateway ---
resource "aws_eip" "nat" {
  domain = "vpc"
}

# --- NAT Gateway ---
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_id
  depends_on    = [var.ig]
  tags = {
    Name = "nat-gateway"
  }
}

# --- Update Private Route Table to use NAT Gateway ---
resource "aws_route" "private_nat_route" {
  route_table_id         = var.route_table_private_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gw
}
