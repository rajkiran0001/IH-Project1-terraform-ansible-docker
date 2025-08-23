# Bastion EC2 instance
resource "aws_instance" "bastion" {
  ami                         = "ami-02c7683e4ca3ebf58" # ubuntu (update as needed)
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_id #declared in the variable and received fom the root main.tf file
  vpc_security_group_ids      = [var.bastion_sg_id]
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
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.public_sg_id]
  associate_public_ip_address = true
  key_name                    = var.key_name
  tags = { 
    Name = "${var.env}-PublicInstance-voteApp-Fe" 
    Environment = var.env 
  }
}
# --- one private Instance postgres---

resource "aws_instance" "private_instance_postgres" {
  ami                         = "ami-02c7683e4ca3ebf58"
  instance_type               = "t2.micro"
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [var.postgres_sg_id]
  associate_public_ip_address = false
  key_name                    = var.key_name
  tags = { 
    Name = "${var.env}-PrivateInstance-voteApp-db" 
    Environment = var.env 
  }
}

# --- Two Private Instances  worker redis---
resource "aws_instance" "private_instance_worker_redis" {
  ami                         = "ami-02c7683e4ca3ebf58"
  instance_type               = "t2.micro"
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [var.private_sg_id]
  associate_public_ip_address = false
  key_name                    = var.key_name
  tags = { 
    Name = "${var.env}-PrivateInstance-voteApp-backend" 
    Environment = var.env 
  }
}