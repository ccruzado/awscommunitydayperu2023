output "cluster_certificate_authority_data" {
    value = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
    value = module.eks.cluster_endpoint
}

output "cluster_id" {
    value = module.eks.cluster_id
}

output "cluster_oidc_issuer_url" {
    value = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
    value = module.eks.oidc_provider_arn
}