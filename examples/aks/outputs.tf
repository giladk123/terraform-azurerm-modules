# Example outputs for the AKS module

# Basic cluster outputs
output "basic_cluster_info" {
  description = "Basic AKS cluster information"
  value = {
    cluster_ids   = module.basic_aks.aks_cluster_ids
    cluster_names = module.basic_aks.aks_cluster_names
    cluster_fqdns = module.basic_aks.aks_cluster_fqdns
    oidc_issuers  = module.basic_aks.oidc_issuer_urls
  }
}

# Kubeconfig for basic cluster (sensitive)
output "basic_cluster_kubeconfig" {
  description = "Kubeconfig for basic AKS cluster"
  value       = module.basic_aks.kube_configs
  sensitive   = true
}

# Node resource groups
output "basic_cluster_node_resource_groups" {
  description = "Node resource groups for basic clusters"
  value       = module.basic_aks.node_resource_groups
}

# Cluster identities
output "basic_cluster_identities" {
  description = "Managed identities for basic clusters"
  value       = module.basic_aks.cluster_identities
}

# Example: How to output specific cluster information
output "dev_cluster_connection_info" {
  description = "Development cluster connection information"
  value = {
    cluster_id  = try(module.basic_aks.aks_cluster_ids["aks-dev-001"], null)
    fqdn        = try(module.basic_aks.aks_cluster_fqdns["aks-dev-001"], null)
    oidc_issuer = try(module.basic_aks.oidc_issuer_urls["aks-dev-001"], null)
  }
}

# Uncomment these when using advanced or private clusters

# output "advanced_cluster_info" {
#   description = "Advanced AKS cluster information"
#   value = {
#     cluster_ids   = module.advanced_aks.aks_cluster_ids
#     cluster_names = module.advanced_aks.aks_cluster_names
#     node_pools    = module.advanced_aks.additional_node_pools
#   }
# }

# output "private_cluster_info" {
#   description = "Private AKS cluster information"
#   value = {
#     cluster_ids     = module.private_aks.aks_cluster_ids
#     private_fqdns   = module.private_aks.aks_cluster_private_fqdns
#     portal_fqdns    = module.private_aks.aks_cluster_portal_fqdns
#   }
# }
