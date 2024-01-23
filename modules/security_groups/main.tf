resource "aws_security_group" "ssh_external_allow" {
  name        = "ssh_external_allow"
  description = "Allow SSH inbound traffic from specified IP addresses."
  vpc_id      = var.vpc_id

  tags = {
    Name = "ssh_external_allow"
  }
}

resource "aws_security_group" "vpc_cidr_allow" {
  name        = "vpc_cidr_allow"
  description = "Allow traffic from the VPC cidr. This is just for testing. Prod rules should be more granular."
  vpc_id      = var.vpc_id

  tags = {
    Name = "vpc_cidr_allow"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_vpc_cidr" {
  security_group_id = aws_security_group.vpc_cidr_allow.id
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_external" {
  count             = length(var.external_ip_list)
  security_group_id = aws_security_group.ssh_external_allow.id
  cidr_ipv4         = element(var.external_ip_list, count.index)
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.ssh_external_allow.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
