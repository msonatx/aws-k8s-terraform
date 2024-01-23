variable "env_name" {
  description = "Environment name prefix"
  type        = string
}

variable "vpc_id" {
  description = "VPC to create the SG in."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "external_ip_list" {
  description = "List of external IPs to grant SSH access to"
  type        = list(string)
}
