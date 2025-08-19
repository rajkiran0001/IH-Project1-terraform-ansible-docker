provider "aws" {
  region = "ap-southeast-1"
}
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
  vpc_id = aws_vpc.main.id
}
# --- Public Subnet ---
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-southeast-1a"
  tags = {
    Name = "public-subnet"
  }
}
# --- Route Table Public ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --- Private Subnet ---
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-1b"
  tags = { Name = "private-subnet" }
}
# Private route table (no NAT, only local traffic)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

# Associate the private subnet with its route table
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Security group for Bastion host
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "public_sg" {
  name   = "public-sg"
  vpc_id = aws_vpc.main.id

  # SSH from Bastion only
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  name   = "private-sg"
  vpc_id = aws_vpc.main.id

  # SSH from Bastion only
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  # Redis from public instance (vote app) and itself (worker container)
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [
      aws_security_group.public_sg.id, # public instance
    ]
     self      = true  # FOR WORKER ITSELF allows traffic from instances in the same SG
  }

  # Egress:  Egress from private instance does not need to specify the public instance — the TCP reply traffic is automatically allowed by AWS stateful security groups.
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "postgres_sg" {
  name   = "postgres_sg"
  vpc_id = aws_vpc.main.id

  # SSH from Bastion only
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
// incomming is allowing port 5432 for public and private instances
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [
      aws_security_group.private_sg.id, # private instance
    ]
  }

  # Egress: outgoing is allowing port 5432 for public and private instances
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Bastion EC2 instance
resource "aws_instance" "bastion" {
  ami                         = "ami-02c7683e4ca3ebf58" # ubuntu (update as needed)
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name                    = "second-key-asia"
  tags = {
    Name = "BastionHost"
  }
}

# --- one public Instance  vote result---
resource "aws_instance" "public_instance_vote_result" {
  ami                         = "ami-02c7683e4ca3ebf58"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.public_sg.id]
  associate_public_ip_address = true
  key_name                    = "second-key-asia"
  tags = { Name = "PublicInstance-vote-result" }
}
# --- one private Instance postgres---

resource "aws_instance" "private_instance_postgres" {
  ami                         = "ami-02c7683e4ca3ebf58"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  associate_public_ip_address = false
  key_name                    = "second-key-asia"
  tags = { Name = "PrivateInstance-postgress" }
}

# --- Two Private Instances  worker redis---
resource "aws_instance" "private_instance_worker_redis" {
  ami                         = "ami-02c7683e4ca3ebf58"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  associate_public_ip_address = false
  key_name                    = "second-key-asia"
  tags = { Name = "PrivateInstance-worker redis" }
}


