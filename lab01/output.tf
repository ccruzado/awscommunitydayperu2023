output "vpc_id" {
    value = module.vpc.vpc_id
}

output "private_subnets" {
    value = module.vpc.private_subnets
}

output "private_subnets_cidr_blocks" {
    value = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets" {
    value = module.vpc.public_subnets
}

output "vpc_cidr_block" {
    value = module.vpc.vpc_cidr_block
}