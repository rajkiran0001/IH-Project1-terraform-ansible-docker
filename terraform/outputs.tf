output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "public_instance_public_ip" {
  value = aws_instance.public_instance_vote_result.public_ip
}
output "private_instance_private_ip" {
  value = aws_instance.private_instance_postgres.private_ip
}
output "vpc_id" {
  value = aws_vpc.main.id
}
output "public_subnet_id" {
  value = aws_subnet.public.id
}
output "private_subnet_id" {
  value = aws_subnet.private.id
}
