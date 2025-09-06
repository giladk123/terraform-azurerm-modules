# AKS Cluster Resource
resource "azurerm_kubernetes_cluster" "this" {
  for_each = var.aks_clusters

  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  dns_prefix          = each.value.dns_prefix
  dns_prefix_private_cluster = each.value.dns_prefix_private_cluster
  kubernetes_version  = each.value.kubernetes_version
  sku_tier           = each.value.sku_tier
  node_resource_group = each.value.node_resource_group

  # Default node pool configuration
  default_node_pool {
    name                         = each.value.default_node_pool.name
    vm_size                      = each.value.default_node_pool.vm_size
    node_count                   = each.value.default_node_pool.node_count
    enable_auto_scaling          = each.value.default_node_pool.auto_scaling_enabled
    min_count                    = each.value.default_node_pool.auto_scaling_enabled ? each.value.default_node_pool.min_count : null
    max_count                    = each.value.default_node_pool.auto_scaling_enabled ? each.value.default_node_pool.max_count : null
    max_pods                     = each.value.default_node_pool.max_pods
    os_disk_size_gb             = each.value.default_node_pool.os_disk_size_gb
    os_disk_type                = each.value.default_node_pool.os_disk_type
    os_sku                      = each.value.default_node_pool.os_sku
    vnet_subnet_id              = each.value.default_node_pool.vnet_subnet_id
    pod_subnet_id               = each.value.default_node_pool.pod_subnet_id
    zones                       = each.value.default_node_pool.zones
    ultra_ssd_enabled           = each.value.default_node_pool.ultra_ssd_enabled
    enable_host_encryption      = each.value.default_node_pool.host_encryption_enabled
    enable_node_public_ip       = each.value.default_node_pool.node_public_ip_enabled
    only_critical_addons_enabled = each.value.default_node_pool.only_critical_addons_enabled
    node_labels                 = each.value.default_node_pool.node_labels
    
    # Upgrade settings
    dynamic "upgrade_settings" {
      for_each = each.value.default_node_pool.upgrade_settings != null ? [each.value.default_node_pool.upgrade_settings] : []
      content {
        max_surge = upgrade_settings.value.max_surge
      }
    }
    
    # Linux OS configuration
    dynamic "linux_os_config" {
      for_each = each.value.default_node_pool.linux_os_config != null ? [each.value.default_node_pool.linux_os_config] : []
      content {
        swap_file_size_mb = linux_os_config.value.swap_file_size_mb
        transparent_huge_page_defrag = linux_os_config.value.transparent_huge_page_defrag
        transparent_huge_page_enabled = linux_os_config.value.transparent_huge_page
        
        dynamic "sysctl_config" {
          for_each = linux_os_config.value.sysctl_config != null ? [linux_os_config.value.sysctl_config] : []
          content {
            fs_aio_max_nr                      = sysctl_config.value.fs_aio_max_nr
            fs_file_max                        = sysctl_config.value.fs_file_max
            fs_inotify_max_user_watches        = sysctl_config.value.fs_inotify_max_user_watches
            fs_nr_open                         = sysctl_config.value.fs_nr_open
            kernel_threads_max                 = sysctl_config.value.kernel_threads_max
            net_core_netdev_max_backlog        = sysctl_config.value.net_core_netdev_max_backlog
            net_core_optmem_max                = sysctl_config.value.net_core_optmem_max
            net_core_rmem_default              = sysctl_config.value.net_core_rmem_default
            net_core_rmem_max                  = sysctl_config.value.net_core_rmem_max
            net_core_somaxconn                 = sysctl_config.value.net_core_somaxconn
            net_core_wmem_default              = sysctl_config.value.net_core_wmem_default
            net_core_wmem_max                  = sysctl_config.value.net_core_wmem_max
            net_ipv4_ip_local_port_range_max   = sysctl_config.value.net_ipv4_ip_local_port_range_max
            net_ipv4_ip_local_port_range_min   = sysctl_config.value.net_ipv4_ip_local_port_range_min
            net_ipv4_neigh_default_gc_thresh1  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh1
            net_ipv4_neigh_default_gc_thresh2  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh2
            net_ipv4_neigh_default_gc_thresh3  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh3
            net_ipv4_tcp_fin_timeout           = sysctl_config.value.net_ipv4_tcp_fin_timeout
            net_ipv4_tcp_keepalive_intvl       = sysctl_config.value.net_ipv4_tcp_keepalive_intvl
            net_ipv4_tcp_keepalive_probes      = sysctl_config.value.net_ipv4_tcp_keepalive_probes
            net_ipv4_tcp_keepalive_time        = sysctl_config.value.net_ipv4_tcp_keepalive_time
            net_ipv4_tcp_max_syn_backlog       = sysctl_config.value.net_ipv4_tcp_max_syn_backlog
            net_ipv4_tcp_max_tw_buckets        = sysctl_config.value.net_ipv4_tcp_max_tw_buckets
            net_ipv4_tcp_tw_reuse              = sysctl_config.value.net_ipv4_tcp_tw_reuse
            net_netfilter_nf_conntrack_buckets = sysctl_config.value.net_netfilter_nf_conntrack_buckets
            net_netfilter_nf_conntrack_max     = sysctl_config.value.net_netfilter_nf_conntrack_max
            vm_max_map_count                   = sysctl_config.value.vm_max_map_count
            vm_swappiness                      = sysctl_config.value.vm_swappiness
            vm_vfs_cache_pressure              = sysctl_config.value.vm_vfs_cache_pressure
          }
        }
      }
    }
    
    # Kubelet configuration
    dynamic "kubelet_config" {
      for_each = each.value.default_node_pool.kubelet_config != null ? [each.value.default_node_pool.kubelet_config] : []
      content {
        allowed_unsafe_sysctls      = kubelet_config.value.allowed_unsafe_sysctls
        container_log_max_line      = kubelet_config.value.container_log_max_line
        container_log_max_size_mb   = kubelet_config.value.container_log_max_size_mb
        cpu_cfs_quota_enabled       = kubelet_config.value.cpu_cfs_quota_enabled
        cpu_cfs_quota_period        = kubelet_config.value.cpu_cfs_quota_period
        cpu_manager_policy          = kubelet_config.value.cpu_manager_policy
        image_gc_high_threshold     = kubelet_config.value.image_gc_high_threshold
        image_gc_low_threshold      = kubelet_config.value.image_gc_low_threshold
        pod_max_pid                 = kubelet_config.value.pod_max_pid
        topology_manager_policy     = kubelet_config.value.topology_manager_policy
      }
    }
  }

  # Identity configuration
  dynamic "identity" {
    for_each = each.value.identity != null ? [each.value.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  # Service principal configuration (alternative to identity)
  dynamic "service_principal" {
    for_each = each.value.service_principal != null ? [each.value.service_principal] : []
    content {
      client_id     = service_principal.value.client_id
      client_secret = service_principal.value.client_secret
    }
  }

  # Network profile
  dynamic "network_profile" {
    for_each = each.value.network_profile != null ? [each.value.network_profile] : []
    content {
      network_plugin      = network_profile.value.network_plugin
      network_mode        = network_profile.value.network_plugin_mode
      network_policy      = network_profile.value.network_policy
      dns_service_ip      = network_profile.value.dns_service_ip
      service_cidr        = network_profile.value.service_cidr
      pod_cidr            = network_profile.value.pod_cidr
      outbound_type       = network_profile.value.outbound_type
      load_balancer_sku   = network_profile.value.load_balancer_sku
      
      # Load balancer profile
      dynamic "load_balancer_profile" {
        for_each = network_profile.value.load_balancer_profile != null ? [network_profile.value.load_balancer_profile] : []
        content {
          managed_outbound_ip_count     = load_balancer_profile.value.managed_outbound_ip_count
          managed_outbound_ipv6_count   = load_balancer_profile.value.managed_outbound_ipv6_count
          outbound_ip_address_ids       = load_balancer_profile.value.outbound_ip_address_ids
          outbound_ip_prefix_ids        = load_balancer_profile.value.outbound_ip_prefix_ids
          outbound_ports_allocated      = load_balancer_profile.value.outbound_ports_allocated
          idle_timeout_in_minutes       = load_balancer_profile.value.idle_timeout_in_minutes
        }
      }
    }
  }

  # Linux profile for SSH access
  dynamic "linux_profile" {
    for_each = each.value.linux_profile != null ? [each.value.linux_profile] : []
    content {
      admin_username = linux_profile.value.admin_username
      
      ssh_key {
        key_data = linux_profile.value.ssh_key.key_data
      }
    }
  }

  # Windows profile
  dynamic "windows_profile" {
    for_each = each.value.windows_profile != null ? [each.value.windows_profile] : []
    content {
      admin_username = windows_profile.value.admin_username
      admin_password = windows_profile.value.admin_password
      license        = windows_profile.value.license
    }
  }

  # Azure Active Directory RBAC
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = each.value.azure_active_directory_role_based_access_control != null ? [each.value.azure_active_directory_role_based_access_control] : []
    content {
      managed                 = azure_active_directory_role_based_access_control.value.managed
      tenant_id               = azure_active_directory_role_based_access_control.value.tenant_id
      admin_group_object_ids  = azure_active_directory_role_based_access_control.value.admin_group_object_ids
      azure_rbac_enabled      = azure_active_directory_role_based_access_control.value.azure_rbac_enabled
      client_app_id           = azure_active_directory_role_based_access_control.value.client_app_id
      server_app_id           = azure_active_directory_role_based_access_control.value.server_app_id
      server_app_secret       = azure_active_directory_role_based_access_control.value.server_app_secret
    }
  }

  # Auto scaler profile
  dynamic "auto_scaler_profile" {
    for_each = each.value.auto_scaler_profile != null ? [each.value.auto_scaler_profile] : []
    content {
      balance_similar_node_groups                = auto_scaler_profile.value.balance_similar_node_groups
      expander                                   = auto_scaler_profile.value.expander
      max_graceful_termination_sec               = auto_scaler_profile.value.max_graceful_termination_sec
      max_node_provisioning_time                 = auto_scaler_profile.value.max_node_provisioning_time
      max_unready_nodes                          = auto_scaler_profile.value.max_unready_nodes
      max_unready_percentage                     = auto_scaler_profile.value.max_unready_percentage
      new_pod_scale_up_delay                     = auto_scaler_profile.value.new_pod_scale_up_delay
      scale_down_delay_after_add                 = auto_scaler_profile.value.scale_down_delay_after_add
      scale_down_delay_after_delete              = auto_scaler_profile.value.scale_down_delay_after_delete
      scale_down_delay_after_failure             = auto_scaler_profile.value.scale_down_delay_after_failure
      scan_interval                              = auto_scaler_profile.value.scan_interval
      scale_down_unneeded                        = auto_scaler_profile.value.scale_down_unneeded
      scale_down_unready                         = auto_scaler_profile.value.scale_down_unready
      scale_down_utilization_threshold           = auto_scaler_profile.value.scale_down_utilization_threshold
      empty_bulk_delete_max                      = auto_scaler_profile.value.empty_bulk_delete_max
      skip_nodes_with_local_storage              = auto_scaler_profile.value.skip_nodes_with_local_storage
      skip_nodes_with_system_pods                = auto_scaler_profile.value.skip_nodes_with_system_pods
    }
  }

  # OMS Agent (Azure Monitor)
  dynamic "oms_agent" {
    for_each = each.value.oms_agent != null ? [each.value.oms_agent] : []
    content {
      log_analytics_workspace_id      = oms_agent.value.log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = oms_agent.value.msi_auth_for_monitoring_enabled
    }
  }

  # Key Vault Secrets Provider
  dynamic "key_vault_secrets_provider" {
    for_each = each.value.key_vault_secrets_provider != null ? [each.value.key_vault_secrets_provider] : []
    content {
      secret_rotation_enabled  = key_vault_secrets_provider.value.secret_rotation_enabled
      secret_rotation_interval = key_vault_secrets_provider.value.secret_rotation_interval
    }
  }

  # Ingress Application Gateway
  dynamic "ingress_application_gateway" {
    for_each = each.value.ingress_application_gateway != null ? [each.value.ingress_application_gateway] : []
    content {
      gateway_id   = ingress_application_gateway.value.gateway_id
      gateway_name = ingress_application_gateway.value.gateway_name
      subnet_cidr  = ingress_application_gateway.value.subnet_cidr
      subnet_id    = ingress_application_gateway.value.subnet_id
    }
  }

  # API server access profile
  dynamic "api_server_access_profile" {
    for_each = each.value.api_server_access_profile != null ? [each.value.api_server_access_profile] : []
    content {
      authorized_ip_ranges = api_server_access_profile.value.authorized_ip_ranges
    }
  }

  # Maintenance window
  dynamic "maintenance_window" {
    for_each = each.value.maintenance_window != null ? [each.value.maintenance_window] : []
    content {
      dynamic "allowed" {
        for_each = maintenance_window.value.allowed != null ? maintenance_window.value.allowed : []
        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }
      
      dynamic "not_allowed" {
        for_each = maintenance_window.value.not_allowed != null ? maintenance_window.value.not_allowed : []
        content {
          start = not_allowed.value.start
          end   = not_allowed.value.end
        }
      }
    }
  }

  # Storage profile
  dynamic "storage_profile" {
    for_each = each.value.storage_profile != null ? [each.value.storage_profile] : []
    content {
      blob_driver_enabled         = storage_profile.value.blob_driver_enabled
      disk_driver_enabled         = storage_profile.value.disk_driver_enabled
      file_driver_enabled         = storage_profile.value.file_driver_enabled
      snapshot_controller_enabled = storage_profile.value.snapshot_controller_enabled
    }
  }

  # Confidential computing
  dynamic "confidential_computing" {
    for_each = each.value.confidential_computing != null ? [each.value.confidential_computing] : []
    content {
      sgx_quote_helper_enabled = confidential_computing.value.sgx_quote_helper_enabled
    }
  }

  # Microsoft Defender
  dynamic "microsoft_defender" {
    for_each = each.value.microsoft_defender != null ? [each.value.microsoft_defender] : []
    content {
      log_analytics_workspace_id = microsoft_defender.value.log_analytics_workspace_id
    }
  }

  # Add-ons and features
  http_application_routing_enabled = each.value.http_application_routing_enabled
  azure_policy_enabled            = each.value.azure_policy_enabled
  open_service_mesh_enabled        = each.value.open_service_mesh_enabled
  image_cleaner_enabled            = each.value.image_cleaner_enabled
  image_cleaner_interval_hours     = each.value.image_cleaner_interval_hours
  workload_identity_enabled        = each.value.workload_identity_enabled
  oidc_issuer_enabled             = each.value.oidc_issuer_enabled

  # Private cluster settings
  private_cluster_enabled                = each.value.private_cluster_enabled
  private_dns_zone_id                   = each.value.private_dns_zone_id
  private_cluster_public_fqdn_enabled   = each.value.private_cluster_public_fqdn_enabled

  # Upgrade settings
  automatic_channel_upgrade = each.value.automatic_upgrade_channel

  tags = each.value.tags
}

# Additional node pools
locals {
  # Flatten additional node pools for all AKS clusters
  additional_node_pools = flatten([
    for cluster_key, cluster_value in var.aks_clusters : [
      for pool_key, pool_value in cluster_value.node_pools : {
        cluster_key                  = cluster_key
        pool_key                     = pool_key
        vm_size                      = pool_value.vm_size
        node_count                   = pool_value.node_count
        auto_scaling_enabled         = pool_value.auto_scaling_enabled
        min_count                    = pool_value.min_count
        max_count                    = pool_value.max_count
        max_pods                     = pool_value.max_pods
        os_disk_size_gb             = pool_value.os_disk_size_gb
        os_disk_type                = pool_value.os_disk_type
        os_sku                      = pool_value.os_sku
        os_type                     = pool_value.os_type
        vnet_subnet_id              = pool_value.vnet_subnet_id
        pod_subnet_id               = pool_value.pod_subnet_id
        zones                       = pool_value.zones
        ultra_ssd_enabled           = pool_value.ultra_ssd_enabled
        host_encryption_enabled     = pool_value.host_encryption_enabled
        node_public_ip_enabled      = pool_value.node_public_ip_enabled
        mode                        = pool_value.mode
        priority                    = pool_value.priority
        eviction_policy             = pool_value.eviction_policy
        spot_max_price              = pool_value.spot_max_price
        node_labels                 = pool_value.node_labels
        node_taints                 = pool_value.node_taints
        upgrade_settings            = pool_value.upgrade_settings
        linux_os_config             = pool_value.linux_os_config
        kubelet_config              = pool_value.kubelet_config
      }
    ]
  ])
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = {
    for pool in local.additional_node_pools : 
    "${pool.cluster_key}-${pool.pool_key}" => pool
  }

  name                  = each.value.pool_key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this[each.value.cluster_key].id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  enable_auto_scaling   = each.value.auto_scaling_enabled
  min_count             = each.value.auto_scaling_enabled ? each.value.min_count : null
  max_count             = each.value.auto_scaling_enabled ? each.value.max_count : null
  max_pods              = each.value.max_pods
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_disk_type          = each.value.os_disk_type
  os_sku                = each.value.os_sku
  os_type               = each.value.os_type
  vnet_subnet_id        = each.value.vnet_subnet_id
  pod_subnet_id         = each.value.pod_subnet_id
  zones                 = each.value.zones
  ultra_ssd_enabled     = each.value.ultra_ssd_enabled
  enable_host_encryption = each.value.host_encryption_enabled
  enable_node_public_ip = each.value.node_public_ip_enabled
  mode                  = each.value.mode
  priority              = each.value.priority
  eviction_policy       = each.value.eviction_policy
  spot_max_price        = each.value.spot_max_price
  node_labels           = each.value.node_labels
  node_taints           = each.value.node_taints

  # Upgrade settings
  dynamic "upgrade_settings" {
    for_each = each.value.upgrade_settings != null ? [each.value.upgrade_settings] : []
    content {
      max_surge = upgrade_settings.value.max_surge
    }
  }

  # Linux OS configuration
  dynamic "linux_os_config" {
    for_each = each.value.linux_os_config != null ? [each.value.linux_os_config] : []
    content {
      swap_file_size_mb = linux_os_config.value.swap_file_size_mb
      transparent_huge_page_defrag = linux_os_config.value.transparent_huge_page_defrag
      transparent_huge_page_enabled = linux_os_config.value.transparent_huge_page
      
      dynamic "sysctl_config" {
        for_each = linux_os_config.value.sysctl_config != null ? [linux_os_config.value.sysctl_config] : []
        content {
          fs_aio_max_nr                      = sysctl_config.value.fs_aio_max_nr
          fs_file_max                        = sysctl_config.value.fs_file_max
          fs_inotify_max_user_watches        = sysctl_config.value.fs_inotify_max_user_watches
          fs_nr_open                         = sysctl_config.value.fs_nr_open
          kernel_threads_max                 = sysctl_config.value.kernel_threads_max
          net_core_netdev_max_backlog        = sysctl_config.value.net_core_netdev_max_backlog
          net_core_optmem_max                = sysctl_config.value.net_core_optmem_max
          net_core_rmem_default              = sysctl_config.value.net_core_rmem_default
          net_core_rmem_max                  = sysctl_config.value.net_core_rmem_max
          net_core_somaxconn                 = sysctl_config.value.net_core_somaxconn
          net_core_wmem_default              = sysctl_config.value.net_core_wmem_default
          net_core_wmem_max                  = sysctl_config.value.net_core_wmem_max
          net_ipv4_ip_local_port_range_max   = sysctl_config.value.net_ipv4_ip_local_port_range_max
          net_ipv4_ip_local_port_range_min   = sysctl_config.value.net_ipv4_ip_local_port_range_min
          net_ipv4_neigh_default_gc_thresh1  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh1
          net_ipv4_neigh_default_gc_thresh2  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh2
          net_ipv4_neigh_default_gc_thresh3  = sysctl_config.value.net_ipv4_neigh_default_gc_thresh3
          net_ipv4_tcp_fin_timeout           = sysctl_config.value.net_ipv4_tcp_fin_timeout
          net_ipv4_tcp_keepalive_intvl       = sysctl_config.value.net_ipv4_tcp_keepalive_intvl
          net_ipv4_tcp_keepalive_probes      = sysctl_config.value.net_ipv4_tcp_keepalive_probes
          net_ipv4_tcp_keepalive_time        = sysctl_config.value.net_ipv4_tcp_keepalive_time
          net_ipv4_tcp_max_syn_backlog       = sysctl_config.value.net_ipv4_tcp_max_syn_backlog
          net_ipv4_tcp_max_tw_buckets        = sysctl_config.value.net_ipv4_tcp_max_tw_buckets
          net_ipv4_tcp_tw_reuse              = sysctl_config.value.net_ipv4_tcp_tw_reuse
          net_netfilter_nf_conntrack_buckets = sysctl_config.value.net_netfilter_nf_conntrack_buckets
          net_netfilter_nf_conntrack_max     = sysctl_config.value.net_netfilter_nf_conntrack_max
          vm_max_map_count                   = sysctl_config.value.vm_max_map_count
          vm_swappiness                      = sysctl_config.value.vm_swappiness
          vm_vfs_cache_pressure              = sysctl_config.value.vm_vfs_cache_pressure
        }
      }
    }
  }

  # Kubelet configuration
  dynamic "kubelet_config" {
    for_each = each.value.kubelet_config != null ? [each.value.kubelet_config] : []
    content {
      allowed_unsafe_sysctls      = kubelet_config.value.allowed_unsafe_sysctls
      container_log_max_line      = kubelet_config.value.container_log_max_line
      container_log_max_size_mb   = kubelet_config.value.container_log_max_size_mb
      cpu_cfs_quota_enabled       = kubelet_config.value.cpu_cfs_quota_enabled
      cpu_cfs_quota_period        = kubelet_config.value.cpu_cfs_quota_period
      cpu_manager_policy          = kubelet_config.value.cpu_manager_policy
      image_gc_high_threshold     = kubelet_config.value.image_gc_high_threshold
      image_gc_low_threshold      = kubelet_config.value.image_gc_low_threshold
      pod_max_pid                 = kubelet_config.value.pod_max_pid
      topology_manager_policy     = kubelet_config.value.topology_manager_policy
    }
  }
}
