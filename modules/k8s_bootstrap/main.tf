resource "aws_instance" "k8s_control" {
  instance_type          = "t3.medium"
  count                  = "1"
  ami                    = var.ubuntu_ami
  key_name               = var.ec2_keypair
  subnet_id              = element(var.public_subnet_ids, 0) # Putting this in a public subnet for testing. Normally would be behind a VPN or jump server.
  iam_instance_profile   = var.iam_role
  vpc_security_group_ids = var.security_groups
  user_data              = templatefile("${path.module}/scripts/control_plane.sh", {join_token_param = var.k8s_join_token_name})

  metadata_options {
    instance_metadata_tags = "enabled"
  }

  tags = {
    "Name"      = "k8scontrol${count.index + 1}"
    "Terraform" = "true"
  }
}

resource "aws_instance" "k8s_worker" {
  count                  = var.worker_node_count
  instance_type          = "t3.medium"
  ami                    = var.ubuntu_ami
  key_name               = var.ec2_keypair
  subnet_id              = element(var.private_subnet_ids, count.index)
  iam_instance_profile   = var.iam_role
  vpc_security_group_ids = var.security_groups
  user_data              = templatefile("${path.module}/scripts/worker.sh", {join_token_param = var.k8s_join_token_name})

  metadata_options {
    instance_metadata_tags = "enabled"
  }

  tags = {
    "Name"      = "k8sworker${count.index + 1}"
    "Terraform" = "true"
  }
}
