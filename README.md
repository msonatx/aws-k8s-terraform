# Bootstrap a K8s cluster on EC2
Example terraform for bootstrapping a VPC (4 private, 4 public subnets, IGW, and NAT GW) and a Kubernetes cluster on EC2 instances. 

#### Modify locals and provider data as needed
```
locals {
  env_name_prefix     = "test"
  vpc_cidr            = "10.0.0.0/16"
  # SSM param for joining worker nodes. This can be named anything.
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
  # External IPs for inbound access 
  external_ip_list = [ 
    "69.235.38.112/32",
    "8.8.8.8/32",
    "4.4.4.4/32"
  ]
}
```
```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "my-s3-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}

provider "aws" {
  region = local.env_region
}
```