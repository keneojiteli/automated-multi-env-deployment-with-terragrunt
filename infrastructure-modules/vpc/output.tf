output "vpc_id" {
  value = aws_vpc.main.id
}

output "priv_subnet_id" {
  description = "Private subnet ID"
  value = aws_subnet.private_subnet[*].id
}

output "pub_subnet_id" {
  description = "Public subnet ID"
  value = aws_subnet.public_subnet[*].id
}

output "vpc_sg" {
  description = "Security group"
  value = aws_security_group.instance_sg.id
}

