output "aks_clusters" {
  description = "Map of all created AKS clusters with their properties"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.this : key => {
      id                         = cluster.id
      name                       = cluster.name
      location                   = cluster.location
      resource_group_name        = cluster.resource_group_name
      dns_prefix                 = cluster.dns_prefix
      fqdn                       = cluster.fqdn
      private_fqdn               = cluster.private_fqdn
      portal_fqdn                = cluster.portal_fqdn
      kubernetes_version         = cluster.kubernetes_version
      current_kubernetes_version = try(cluster.current_kubernetes_version, null)
      node_resource_group        = cluster.node_resource_group
      node_resource_group_id     = try(cluster.node_resource_group_id, null)
      oidc_issuer_url            = try(cluster.oidc_issuer_url, null)

      # Kube config (sensitive)
      kube_config_raw       = cluster.kube_config_raw
      kube_admin_config_raw = cluster.kube_admin_config_raw

      # Identity information
      identity         = cluster.identity
      kubelet_identity = cluster.kubelet_identity

      # Network profile
      network_profile = cluster.network_profile

      # Add-on identities
      oms_agent_identity                   = try(cluster.oms_agent[0].oms_agent_identity, null)
      key_vault_secrets_provider_identity  = try(cluster.key_vault_secrets_provider[0].secret_identity, null)
      ingress_application_gateway_identity = try(cluster.ingress_application_gateway[0].ingress_application_gateway_identity, null)
    }
  }
  sensitive = true
}

output "aks_cluster_ids" {
  description = "Map of AKS cluster names to their resource IDs"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.this : key => cluster.id
  }
}

output "aks_cluster_names" {
  description = "Map of AKS cluster keys to their actual names"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.this : key => cluster.name
  }
}

output "aks_cluster_fqdns" {
  description = "Map of AKS cluster names to their FQDNs"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.this : key => cluster.fqdn
  }
}

output "aks_cluster_private_fqdns" {
  description = "Map of AKS cluster names to their private FQDNs (for private clusters)"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.this : key => cluster.private_fqdn
  }
}

output "aks_cluster_portal_fqdns" {
  description = "Map of AKS cluster names to their portal FQDNs (for private clusters)"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.this : key => cluster.portal_fqdn
  }
}

output "kube_configs" {
  description = "Map of AKS cluster names to their kubeconfig contents"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.this : key => cluster.kube_config_raw
  }
  sensitive = true
}

output "kube_admin_configs" {
  description = "Map of AKS cluster names to their admin kubeconfig contents"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.this : key => cluster.kube_admin_config_raw
  }
  sensitive = true
}

output "oidc_issuer_urls" {
  description = "Map of AKS cluster names to their OIDC issuer URLs"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.this : key => try(cluster.oidc_issuer_url, null)
  }
}

output "node_resource_groups" {
  description = "Map of AKS cluster names to their node resource group names"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.this : key => cluster.node_resource_group
  }
}

output "node_resource_group_ids" {
  description = "Map of AKS cluster names to their node resource group IDs"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.this : key => try(cluster.node_resource_group_id, null)
  }
}

output "cluster_identities" {
  description = "Map of AKS cluster identities (managed identity information)"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.this : key => cluster.identity
  }
}

output "kubelet_identities" {
  description = "Map of AKS cluster kubelet identities"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.this : key => cluster.kubelet_identity
  }
}

output "network_profiles" {
  description = "Map of AKS cluster network profiles"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.this : key => cluster.network_profile
  }
}

output "additional_node_pools" {
  description = "Map of all created additional node pools"
  value = {
    for key, pool in azurerm_kubernetes_cluster_node_pool.this : key => {
      id                    = pool.id
      name                  = pool.name
      kubernetes_cluster_id = pool.kubernetes_cluster_id
      vm_size               = pool.vm_size
      node_count            = pool.node_count
      auto_scaling_enabled  = pool.enable_auto_scaling
      min_count             = pool.min_count
      max_count             = pool.max_count
      os_type               = pool.os_type
      os_sku                = pool.os_sku
      zones                 = pool.zones
      mode                  = pool.mode
      priority              = pool.priority
      spot_max_price        = pool.spot_max_price
    }
  }
}

output "oms_agent_identities" {
  description = "Map of OMS Agent identities for clusters with monitoring enabled"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.this : key => try(cluster.oms_agent[0].oms_agent_identity, null)
    if try(cluster.oms_agent[0], null) != null
  }
}

output "key_vault_secrets_provider_identities" {
  description = "Map of Key Vault Secrets Provider identities for clusters with the feature enabled"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.this : key => try(cluster.key_vault_secrets_provider[0].secret_identity, null)
    if try(cluster.key_vault_secrets_provider[0], null) != null
  }
}

output "ingress_application_gateway_identities" {
  description = "Map of Ingress Application Gateway identities for clusters with AGIC enabled"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.this : key => try(cluster.ingress_application_gateway[0].ingress_application_gateway_identity, null)
    if try(cluster.ingress_application_gateway[0], null) != null
  }
}

output "effective_gateway_ids" {
  description = "Map of effective Application Gateway IDs for clusters with AGIC enabled"
  value = {
    for key, cluster in azurerm_kubernetes_cluster.this : key => try(cluster.ingress_application_gateway[0].effective_gateway_id, null)
    if try(cluster.ingress_application_gateway[0], null) != null
  }
}
