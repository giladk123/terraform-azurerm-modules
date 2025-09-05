variable "aks_clusters" {
  description = "Map of AKS cluster configurations decoded from JSON"
  type = map(object({
    # Required basic configuration
    resource_group_name = string
    location            = string
    dns_prefix          = optional(string)
    dns_prefix_private_cluster = optional(string)
    kubernetes_version  = optional(string)
    sku_tier           = optional(string, "Free")
    node_resource_group = optional(string)
    
    # Identity configuration
    identity = object({
      type         = string
      identity_ids = optional(list(string))
    })
    
    # Service principal (alternative to identity)
    service_principal = optional(object({
      client_id     = string
      client_secret = string
    }))
    
    # Default node pool configuration
    default_node_pool = object({
      name                         = string
      vm_size                      = string
      node_count                   = optional(number, 1)
      auto_scaling_enabled         = optional(bool, false)
      min_count                    = optional(number)
      max_count                    = optional(number)
      max_pods                     = optional(number)
      os_disk_size_gb             = optional(number)
      os_disk_type                = optional(string, "Managed")
      os_sku                      = optional(string, "Ubuntu")
      vnet_subnet_id              = optional(string)
      pod_subnet_id               = optional(string)
      zones                       = optional(list(string))
      ultra_ssd_enabled           = optional(bool, false)
      host_encryption_enabled     = optional(bool, false)
      node_public_ip_enabled      = optional(bool, false)
      only_critical_addons_enabled = optional(bool, false)
      temporary_name_for_rotation = optional(string)
      
      # Node labels and taints
      node_labels = optional(map(string), {})
      
      # Upgrade settings
      upgrade_settings = optional(object({
        drain_timeout_in_minutes     = optional(number)
        node_soak_duration_in_minutes = optional(number)
        max_surge                    = string
      }))
      
      # Linux OS configuration
      linux_os_config = optional(object({
        swap_file_size_mb = optional(number)
        transparent_huge_page_defrag = optional(string)
        transparent_huge_page = optional(string)
        sysctl_config = optional(object({
          fs_aio_max_nr                      = optional(number)
          fs_file_max                        = optional(number)
          fs_inotify_max_user_watches        = optional(number)
          fs_nr_open                         = optional(number)
          kernel_threads_max                 = optional(number)
          net_core_netdev_max_backlog        = optional(number)
          net_core_optmem_max                = optional(number)
          net_core_rmem_default              = optional(number)
          net_core_rmem_max                  = optional(number)
          net_core_somaxconn                 = optional(number)
          net_core_wmem_default              = optional(number)
          net_core_wmem_max                  = optional(number)
          net_ipv4_ip_local_port_range_max   = optional(number)
          net_ipv4_ip_local_port_range_min   = optional(number)
          net_ipv4_neigh_default_gc_thresh1  = optional(number)
          net_ipv4_neigh_default_gc_thresh2  = optional(number)
          net_ipv4_neigh_default_gc_thresh3  = optional(number)
          net_ipv4_tcp_fin_timeout           = optional(number)
          net_ipv4_tcp_keepalive_intvl       = optional(number)
          net_ipv4_tcp_keepalive_probes      = optional(number)
          net_ipv4_tcp_keepalive_time        = optional(number)
          net_ipv4_tcp_max_syn_backlog       = optional(number)
          net_ipv4_tcp_max_tw_buckets        = optional(number)
          net_ipv4_tcp_tw_reuse              = optional(bool)
          net_netfilter_nf_conntrack_buckets = optional(number)
          net_netfilter_nf_conntrack_max     = optional(number)
          vm_max_map_count                   = optional(number)
          vm_swappiness                      = optional(number)
          vm_vfs_cache_pressure              = optional(number)
        }))
      }))
      
      # Kubelet configuration
      kubelet_config = optional(object({
        allowed_unsafe_sysctls      = optional(list(string))
        container_log_max_line      = optional(number)
        container_log_max_size_mb   = optional(number)
        cpu_cfs_quota_enabled       = optional(bool, true)
        cpu_cfs_quota_period        = optional(string)
        cpu_manager_policy          = optional(string)
        image_gc_high_threshold     = optional(number)
        image_gc_low_threshold      = optional(number)
        pod_max_pid                 = optional(number)
        topology_manager_policy     = optional(string)
      }))
    })
    
    # Additional node pools
    node_pools = optional(map(object({
      vm_size                      = string
      node_count                   = optional(number, 1)
      auto_scaling_enabled         = optional(bool, false)
      min_count                    = optional(number)
      max_count                    = optional(number)
      max_pods                     = optional(number)
      os_disk_size_gb             = optional(number)
      os_disk_type                = optional(string, "Managed")
      os_sku                      = optional(string, "Ubuntu")
      os_type                     = optional(string, "Linux")
      vnet_subnet_id              = optional(string)
      pod_subnet_id               = optional(string)
      zones                       = optional(list(string))
      ultra_ssd_enabled           = optional(bool, false)
      host_encryption_enabled     = optional(bool, false)
      node_public_ip_enabled      = optional(bool, false)
      mode                        = optional(string, "User")
      priority                    = optional(string, "Regular")
      eviction_policy             = optional(string)
      spot_max_price              = optional(number)
      temporary_name_for_rotation = optional(string)
      
      # Node labels and taints
      node_labels = optional(map(string), {})
      node_taints = optional(list(string), [])
      
      # Upgrade settings
      upgrade_settings = optional(object({
        drain_timeout_in_minutes     = optional(number)
        node_soak_duration_in_minutes = optional(number)
        max_surge                    = string
      }))
      
      # Linux OS configuration
      linux_os_config = optional(object({
        swap_file_size_mb = optional(number)
        transparent_huge_page_defrag = optional(string)
        transparent_huge_page = optional(string)
        sysctl_config = optional(object({
          fs_aio_max_nr                      = optional(number)
          fs_file_max                        = optional(number)
          fs_inotify_max_user_watches        = optional(number)
          fs_nr_open                         = optional(number)
          kernel_threads_max                 = optional(number)
          net_core_netdev_max_backlog        = optional(number)
          net_core_optmem_max                = optional(number)
          net_core_rmem_default              = optional(number)
          net_core_rmem_max                  = optional(number)
          net_core_somaxconn                 = optional(number)
          net_core_wmem_default              = optional(number)
          net_core_wmem_max                  = optional(number)
          net_ipv4_ip_local_port_range_max   = optional(number)
          net_ipv4_ip_local_port_range_min   = optional(number)
          net_ipv4_neigh_default_gc_thresh1  = optional(number)
          net_ipv4_neigh_default_gc_thresh2  = optional(number)
          net_ipv4_neigh_default_gc_thresh3  = optional(number)
          net_ipv4_tcp_fin_timeout           = optional(number)
          net_ipv4_tcp_keepalive_intvl       = optional(number)
          net_ipv4_tcp_keepalive_probes      = optional(number)
          net_ipv4_tcp_keepalive_time        = optional(number)
          net_ipv4_tcp_max_syn_backlog       = optional(number)
          net_ipv4_tcp_max_tw_buckets        = optional(number)
          net_ipv4_tcp_tw_reuse              = optional(bool)
          net_netfilter_nf_conntrack_buckets = optional(number)
          net_netfilter_nf_conntrack_max     = optional(number)
          vm_max_map_count                   = optional(number)
          vm_swappiness                      = optional(number)
          vm_vfs_cache_pressure              = optional(number)
        }))
      }))
      
      # Kubelet configuration
      kubelet_config = optional(object({
        allowed_unsafe_sysctls      = optional(list(string))
        container_log_max_line      = optional(number)
        container_log_max_size_mb   = optional(number)
        cpu_cfs_quota_enabled       = optional(bool, true)
        cpu_cfs_quota_period        = optional(string)
        cpu_manager_policy          = optional(string)
        image_gc_high_threshold     = optional(number)
        image_gc_low_threshold      = optional(number)
        pod_max_pid                 = optional(number)
        topology_manager_policy     = optional(string)
      }))
    })), {})
    
    # Network profile
    network_profile = optional(object({
      network_plugin      = optional(string, "kubenet")
      network_plugin_mode = optional(string)
      network_policy      = optional(string)
      network_data_plane  = optional(string, "azure")
      dns_service_ip      = optional(string)
      service_cidr        = optional(string)
      service_cidrs       = optional(list(string))
      pod_cidr            = optional(string)
      pod_cidrs           = optional(list(string))
      outbound_type       = optional(string, "loadBalancer")
      load_balancer_sku   = optional(string, "standard")
      
      # Load balancer profile
      load_balancer_profile = optional(object({
        managed_outbound_ip_count     = optional(number)
        managed_outbound_ipv6_count   = optional(number)
        outbound_ip_address_ids       = optional(list(string))
        outbound_ip_prefix_ids        = optional(list(string))
        outbound_ports_allocated      = optional(number)
        idle_timeout_in_minutes       = optional(number, 30)
        backend_pool_type             = optional(string, "NodeIPConfiguration")
      }))
    }))
    
    # Linux profile for SSH access
    linux_profile = optional(object({
      admin_username = string
      ssh_key = object({
        key_data = string
      })
    }))
    
    # Windows profile
    windows_profile = optional(object({
      admin_username = string
      admin_password = string
      license        = optional(string)
    }))
    
    # RBAC and Azure AD integration
    azure_active_directory_role_based_access_control = optional(object({
      tenant_id               = optional(string)
      admin_group_object_ids  = optional(list(string))
      azure_rbac_enabled      = optional(bool, false)
    }))
    
    # Auto scaler profile
    auto_scaler_profile = optional(object({
      balance_similar_node_groups                = optional(bool, false)
      expander                                   = optional(string, "random")
      max_graceful_termination_sec               = optional(number, 600)
      max_node_provisioning_time                 = optional(string, "15m")
      max_unready_nodes                          = optional(number, 3)
      max_unready_percentage                     = optional(number, 45)
      new_pod_scale_up_delay                     = optional(string, "10s")
      scale_down_delay_after_add                 = optional(string, "10m")
      scale_down_delay_after_delete              = optional(string)
      scale_down_delay_after_failure             = optional(string, "3m")
      scan_interval                              = optional(string, "10s")
      scale_down_unneeded                        = optional(string, "10m")
      scale_down_unready                         = optional(string, "20m")
      scale_down_utilization_threshold           = optional(number, 0.5)
      empty_bulk_delete_max                      = optional(number, 10)
      skip_nodes_with_local_storage              = optional(bool, false)
      skip_nodes_with_system_pods                = optional(bool, true)
    }))
    
    # Add-ons and integrations
    http_application_routing_enabled = optional(bool, false)
    azure_policy_enabled            = optional(bool, false)
    open_service_mesh_enabled        = optional(bool, false)
    image_cleaner_enabled            = optional(bool, false)
    image_cleaner_interval_hours     = optional(number)
    workload_identity_enabled        = optional(bool, false)
    oidc_issuer_enabled             = optional(bool, false)
    
    # OMS Agent (Azure Monitor)
    oms_agent = optional(object({
      log_analytics_workspace_id      = string
      msi_auth_for_monitoring_enabled = optional(bool, false)
    }))
    
    # Key Vault Secrets Provider
    key_vault_secrets_provider = optional(object({
      secret_rotation_enabled  = optional(bool, false)
      secret_rotation_interval = optional(string, "2m")
    }))
    
    # Ingress Application Gateway
    ingress_application_gateway = optional(object({
      gateway_id   = optional(string)
      gateway_name = optional(string)
      subnet_cidr  = optional(string)
      subnet_id    = optional(string)
    }))
    
    # Private cluster configuration
    private_cluster_enabled                = optional(bool, false)
    private_dns_zone_id                   = optional(string)
    private_cluster_public_fqdn_enabled   = optional(bool, false)
    
    # API server access profile
    api_server_access_profile = optional(object({
      authorized_ip_ranges = optional(list(string))
    }))
    
    # Maintenance windows
    maintenance_window = optional(object({
      allowed = optional(list(object({
        day   = string
        hours = list(number)
      })))
      not_allowed = optional(list(object({
        start = string
        end   = string
      })))
    }))
    
    # Upgrade settings
    automatic_upgrade_channel    = optional(string, "none")
    node_os_upgrade_channel     = optional(string, "NodeImage")
    kubernetes_version          = optional(string)
    
    # Storage profile
    storage_profile = optional(object({
      blob_driver_enabled         = optional(bool, false)
      disk_driver_enabled         = optional(bool, true)
      file_driver_enabled         = optional(bool, true)
      snapshot_controller_enabled = optional(bool, true)
    }))
    
    # Confidential computing
    confidential_computing = optional(object({
      sgx_quote_helper_enabled = bool
    }))
    
    # Microsoft Defender
    microsoft_defender = optional(object({
      log_analytics_workspace_id = string
    }))
    
    # Tags
    tags = optional(map(string), {})
  }))
}
