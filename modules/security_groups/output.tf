output "ssh_external_sg" {
  value = aws_security_group.ssh_external_allow.id
}

output "vpc_cidr_allow_sg" {
  value = aws_security_group.vpc_cidr_allow.id
}