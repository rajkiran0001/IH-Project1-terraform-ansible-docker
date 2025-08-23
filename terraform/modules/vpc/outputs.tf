output "vpc_id" { value = aws_vpc.main.id }
output "public_subnet_id" { value = aws_subnet.public.id }
output "private_subnet_id" { value = aws_subnet.private.id }
output "internet_gateway_id" { value = aws_internet_gateway.gw.id }
output "route_table_public_id" { value = aws_route_table.public.id }
output "route_table_private_id" { value = aws_route_table.private.id }
output "nat_gw" { value = aws_nat_gateway.nat_gw.id }
output "ig" { value = aws_internet_gateway.gw }
