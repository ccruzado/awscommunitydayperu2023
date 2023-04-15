#############################################################################
# PROVIDERS
#############################################################################
provider "aws" {
  region  = var.aws_region
}

#############################################################################
# ETIQUETAS
#############################################################################
locals {
  common_tags = {
    t_ambiente      = var.t_ambiente
    t_app           = var.t_app
  }
}

#############################################################################
# VPC REMOTE STATE
#############################################################################
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket  = "iacawscommunityday2023"
    key     = "lab01/terraform.tfstate"
    region  = "us-east-1"
  }
}
#############################################################################
# EKS
#############################################################################

module "eks" {
  source          = "terraform-aws-modules/eks/aws"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  enable_irsa = true
  
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids      = data.terraform_remote_state.vpc.outputs.private_subnets
  
  cluster_enabled_log_types               = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cloudwatch_log_group_retention_in_days  = 7
  create_cloudwatch_log_group             = true

  eks_managed_node_groups = {

    bottlerocket = {
      ami_type = "BOTTLEROCKET_x86_64"
      platform = "bottlerocket"
      disk_size = var.eks_disk_size
      instance_types = var.eks_instance_types
      min_size     = 1
      max_size     = 2
      desired_size = 2

      create_security_group          = true
      security_group_name            = "sgr-eks-managed-node-groups"
      security_group_use_name_prefix = false
      security_group_description     = "EKS managed node group security group"
      security_group_rules = {
        ingress = {
          protocol    = "tcp"
          from_port   = 9443
          to_port     = 9443
          type        = "ingress"
          cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
        }
      }
      security_group_tags = merge(
        local.common_tags
      )
      
      tags = merge(
        local.common_tags
      )
    }
  }

  tags = merge(
    local.common_tags
  )
}
