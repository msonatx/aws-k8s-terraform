variable "env_name" {
  description = "Environment name prefix"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR (e.g. 10.0.0.0/16)"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "List of valid CIDRs for the VPC's private subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of valid CIDRs for the VPC's public subnets"
  type        = list(string)
}
