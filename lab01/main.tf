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
# VPC
#############################################################################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr_range

  azs               = var.vpc_azs
  database_subnets  = var.vpc_database_subnets
  private_subnets   = var.vpc_private_subnets
  public_subnets    = var.vpc_public_subnets


  enable_dns_hostnames = true
  enable_dns_support   = true
  
  enable_nat_gateway = true
  single_nat_gateway  = true
  one_nat_gateway_per_az = false

  enable_flow_log           = true
  flow_log_destination_type = "s3"
  flow_log_destination_arn  = module.s3_bucket.s3_bucket_arn

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  tags = merge(
    local.common_tags
  )
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"

  bucket        = "s3-vpc-flow-logs-${var.t_ambiente}"

  force_destroy = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  
  tags = merge(
    local.common_tags
  )
}