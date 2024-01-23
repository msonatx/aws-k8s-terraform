variable "ubuntu_ami" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "ec2_keypair" {
  description = "Keypair for EC2 instance"
  type        = string
}

variable "worker_node_count" {
  description = "The number of worker nodes to create"
  type        = string
}

variable "k8s_join_token_name" {
  description = "The name of the k8s_join_token SSM parameter"
  type        = string
}

variable "iam_role" {
  description = "The IAM role to be assigned to the k8s instances"
  type        = string
}

variable "private_subnet_ids" {
  description = "The subnet IDs to use for the worker nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "The subnet IDs to use for the worker nodes"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security groups to attach to the k8s instances"
  type        = list(string)
}
