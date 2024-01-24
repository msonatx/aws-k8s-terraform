locals {
  env_name_prefix     = "test"
  vpc_cidr            = "10.0.0.0/16"
  k8s_join_token_name = "k8s_join_token"
  worker_node_count = 3
  private_subnet_cidrs = [
    cidrsubnet(local.vpc_cidr, 3, 0),
    cidrsubnet(local.vpc_cidr, 3, 1),
    cidrsubnet(local.vpc_cidr, 3, 2),
    cidrsubnet(local.vpc_cidr, 3, 3),
  ]
  public_subnet_cidrs = [
    cidrsubnet(local.vpc_cidr, 3, 4),
    cidrsubnet(local.vpc_cidr, 3, 5),
    cidrsubnet(local.vpc_cidr, 3, 6),
    cidrsubnet(local.vpc_cidr, 3, 7),
  ]
  ubuntu_ami_id = "ami-07b36ea9852e986ad"
  ec2_keypair   = "my-ec2-keypair"
  env_region    = "us-east-2"
  external_ip_list = [
    "69.235.38.112/32",
    "8.8.8.8/32",
    "4.4.4.4/32"
  ]
}

module "ssm" {
  source              = "./modules/ssm"
  k8s_join_token_name = local.k8s_join_token_name
}

module "iam" {
  source             = "./modules/iam"
  k8s_join_param_arn = module.ssm.k8s_join_param_arn
}

module "vpc-core" {
  source               = "./modules/vpc"
  env_name             = local.env_name_prefix
  vpc_cidr             = local.vpc_cidr
  private_subnet_cidrs = local.private_subnet_cidrs
  public_subnet_cidrs  = local.public_subnet_cidrs
}

module "sgs" {
  source           = "./modules/security_groups"
  vpc_id           = module.vpc-core.vpc_id
  vpc_cidr         = local.vpc_cidr
  env_name         = local.env_name_prefix
  external_ip_list = local.external_ip_list
}

module "k8s-bootstrap" {
  source              = "./modules/k8s_bootstrap"
  depends_on          = [module.vpc-core]
  ubuntu_ami          = local.ubuntu_ami_id
  ec2_keypair         = local.ec2_keypair
  iam_role            = module.iam.k8s_ec2_instance_profile
  worker_node_count   = local.worker_node_count
  private_subnet_ids  = module.vpc-core.private_subnet_ids
  public_subnet_ids   = module.vpc-core.public_subnet_ids
  k8s_join_token_name = local.k8s_join_token_name
  security_groups = [
    module.sgs.ssh_external_sg,
    module.sgs.vpc_cidr_allow_sg
  ]
}
