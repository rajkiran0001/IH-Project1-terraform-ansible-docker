provider "aws" {
  region = "ap-southeast-1"
}

module "vpc" {
  source              = "../../terraform/modules/vpc"
  vpc_id              = module.vpc.vpc_id
  public_subnet_id    = module.vpc.public_subnet_id
  private_subnet_id   = module.vpc.private_subnet_id
  internet_gateway_id = module.vpc.internet_gateway_id
  route_table_public_id = module.vpc.route_table_public_id
  route_table_private_id = module.vpc.route_table_private_id
  ig                  = module.vpc.ig
  nat_gw              = module.vpc.nat_gw
  vpc_cidr            = "10.0.0.0/16"
  vpc_name            = "main-vpc"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  public_az           = "ap-southeast-1a"
  private_az          = "ap-southeast-1b"
}

module "security_groups" {
  source   = "../../terraform/modules/security-groups"
  vpc_id   = module.vpc.vpc_id
  bastion_sg_id = module.security_groups.bastion_sg_id
  allowed_ip = "79.221.193.190/32"
}

module "ec2" {
  source            = "../../terraform/modules/ec2"
  ami               = "ami-02c7683e4ca3ebf58"
  key_name          = "second-key-asia"
  public_subnet_id  = module.vpc.public_subnet_id # received from the module output
  private_subnet_id = module.vpc.private_subnet_id
  bastion_sg_id     = module.security_groups.bastion_sg_id
  public_sg_id      = module.security_groups.public_sg_id
  private_sg_id     = module.security_groups.private_sg_id
  postgres_sg_id    = module.security_groups.postgres_sg_id
  env                 = "dev"

}

