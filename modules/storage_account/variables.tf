variable "storage_accounts" {
  description = "Map of storage account configurations decoded from JSON"
  type = map(object({
    resource_group_name             = string
    location                        = string
    account_tier                    = string
    account_replication_type        = string
    account_kind                    = optional(string, "StorageV2")
    access_tier                     = optional(string, "Hot")
    https_traffic_only_enabled      = optional(bool, true)
    min_tls_version                 = optional(string, "TLS1_2")
    allow_nested_items_to_be_public = optional(bool, false)
    shared_access_key_enabled       = optional(bool, true)
    is_hns_enabled                  = optional(bool, false)
    nfsv3_enabled                   = optional(bool, false)
    large_file_share_enabled        = optional(bool, false)
    public_network_access_enabled   = optional(bool, true)
    tags                            = optional(map(string), {})
    cross_tenant_replication_enabled = optional(bool, true)

    # Blob properties
    blob_properties = optional(object({
      enable_versioning        = optional(bool, false)
      last_access_time_enabled = optional(bool, false)
      change_feed_enabled      = optional(bool, false)
      
      delete_retention_policy = optional(object({
        enabled = bool
        days    = optional(number, 7)
      }))
      
      container_delete_retention_policy = optional(object({
        enabled = bool
        days    = optional(number, 7)
      }))
    }))

    # Network rules
    network_rules = optional(object({
      default_action             = optional(string, "Deny")
      bypass                     = optional(set(string), ["AzureServices"])
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
    }))

    # Static website
    static_website = optional(object({
      enabled         = bool
      index_document  = optional(string)
      error_404_document = optional(string)
    }))

    # Containers
    containers = optional(map(object({
      container_access_type = optional(string, "private")
      metadata              = optional(map(string), {})
    })), {})

    # File shares
    file_shares = optional(map(object({
      quota             = number
      access_tier       = optional(string, "Hot")
      enabled_protocol  = optional(string)
      metadata          = optional(map(string), {})
    })), {})

    # Queues
    queues = optional(map(object({
      metadata = optional(map(string), {})
    })), {})

    # Tables
    tables = optional(map(object({
      metadata = optional(map(string), {})
    })), {})

    # Lifecycle management
    lifecycle_rules = optional(list(object({
      name    = string
      enabled = bool
      
      blob_types = optional(list(string), ["blockBlob"])
      
      base_blob = optional(object({
        tier_to_cool_after_days    = optional(number)
        tier_to_archive_after_days = optional(number)
        delete_after_days          = optional(number)
      }))
      
      snapshot = optional(object({
        tier_to_cool_after_days    = optional(number)
        tier_to_archive_after_days = optional(number)
        delete_after_days          = optional(number)
      }))
      
      version = optional(object({
        tier_to_cool_after_days    = optional(number)
        tier_to_archive_after_days = optional(number)
        delete_after_days          = optional(number)
      }))
    })), [])

    # Encryption
    encryption = optional(object({
      key_source                       = optional(string, "Microsoft.Storage")
      infrastructure_encryption_enabled = optional(bool, false)
    }))

    # Identity
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))

    # Private Endpoints
    private_endpoints = optional(map(object({
      subnet_id                            = string
      private_dns_zone_group_name          = optional(string, "default")
      private_dns_zone_ids                 = optional(list(string), [])
      subresource_names                    = list(string)
      private_service_connection_name      = optional(string)
      is_manual_connection                 = optional(bool, false)
      request_message                      = optional(string)
      tags                                 = optional(map(string), {})
    })), {})
  }))
} 