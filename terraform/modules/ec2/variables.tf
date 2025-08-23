variable "ami" {}
variable "key_name" {}
variable "public_subnet_id" {}
variable "private_subnet_id" {}
variable "bastion_sg_id" {}
variable "public_sg_id" {}
variable "private_sg_id" {}
variable "postgres_sg_id" {}
variable "env" {
    description = "Environment name"
    type = string
}
