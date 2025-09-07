# Storage Account Resource
resource "azurerm_storage_account" "this" {
  for_each = var.storage_accounts

  name                             = each.key
  resource_group_name              = each.value.resource_group_name
  location                         = each.value.location
  account_tier                     = each.value.account_tier
  account_replication_type         = each.value.account_replication_type
  account_kind                     = each.value.account_kind
  access_tier                      = each.value.access_tier
  enable_https_traffic_only        = each.value.https_traffic_only_enabled
  min_tls_version                  = each.value.min_tls_version
  allow_nested_items_to_be_public  = each.value.allow_nested_items_to_be_public
  shared_access_key_enabled        = each.value.shared_access_key_enabled
  is_hns_enabled                   = each.value.is_hns_enabled
  nfsv3_enabled                    = each.value.nfsv3_enabled
  large_file_share_enabled         = each.value.large_file_share_enabled
  public_network_access_enabled    = each.value.public_network_access_enabled
  cross_tenant_replication_enabled = try(each.value.cross_tenant_replication_enabled, true)

  # Blob properties
  dynamic "blob_properties" {
    for_each = each.value.blob_properties != null ? [each.value.blob_properties] : []
    content {
      versioning_enabled       = blob_properties.value.enable_versioning
      last_access_time_enabled = blob_properties.value.last_access_time_enabled
      change_feed_enabled      = blob_properties.value.change_feed_enabled

      dynamic "delete_retention_policy" {
        for_each = blob_properties.value.delete_retention_policy != null ? [blob_properties.value.delete_retention_policy] : []
        content {
          days = delete_retention_policy.value.enabled ? delete_retention_policy.value.days : null
        }
      }

      dynamic "container_delete_retention_policy" {
        for_each = blob_properties.value.container_delete_retention_policy != null ? [blob_properties.value.container_delete_retention_policy] : []
        content {
          days = container_delete_retention_policy.value.enabled ? container_delete_retention_policy.value.days : null
        }
      }
    }
  }

  # Network rules
  dynamic "network_rules" {
    for_each = each.value.network_rules != null ? [each.value.network_rules] : []
    content {
      default_action             = network_rules.value.default_action
      bypass                     = network_rules.value.bypass
      ip_rules                   = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
    }
  }

  # Static website
  dynamic "static_website" {
    for_each = each.value.static_website != null ? (each.value.static_website.enabled ? [each.value.static_website] : []) : []
    content {
      index_document     = static_website.value.index_document
      error_404_document = static_website.value.error_404_document
    }
  }

  # Identity
  dynamic "identity" {
    for_each = each.value.identity != null ? [each.value.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  tags = each.value.tags
}

# Storage Containers
locals {
  # Flatten storage accounts with their containers
  storage_containers = flatten([
    for sa_key, sa_value in var.storage_accounts : [
      for container_key, container_value in sa_value.containers : {
        storage_account_key   = sa_key
        container_key         = container_key
        container_access_type = container_value.container_access_type
        metadata              = container_value.metadata
      }
    ]
  ])
}

resource "azurerm_storage_container" "this" {
  for_each = {
    for container in local.storage_containers :
    "${container.storage_account_key}-${container.container_key}" => container
  }

  name                  = each.value.container_key
  storage_account_name  = azurerm_storage_account.this[each.value.storage_account_key].name
  container_access_type = each.value.container_access_type
  metadata              = each.value.metadata
}

# File Shares
locals {
  # Flatten storage accounts with their file shares
  storage_file_shares = flatten([
    for sa_key, sa_value in var.storage_accounts : [
      for share_key, share_value in sa_value.file_shares : {
        storage_account_key = sa_key
        share_key           = share_key
        quota               = share_value.quota
        access_tier         = share_value.access_tier
        enabled_protocol    = share_value.enabled_protocol
        metadata            = share_value.metadata
      }
    ]
  ])
}

resource "azurerm_storage_share" "this" {
  for_each = {
    for share in local.storage_file_shares :
    "${share.storage_account_key}-${share.share_key}" => share
  }

  name                 = each.value.share_key
  storage_account_name = azurerm_storage_account.this[each.value.storage_account_key].name
  quota                = each.value.quota
  access_tier          = each.value.access_tier
  enabled_protocol     = each.value.enabled_protocol
  metadata             = each.value.metadata
}

# Queues
locals {
  # Flatten storage accounts with their queues
  storage_queues = flatten([
    for sa_key, sa_value in var.storage_accounts : [
      for queue_key, queue_value in sa_value.queues : {
        storage_account_key = sa_key
        queue_key           = queue_key
        metadata            = queue_value.metadata
      }
    ]
  ])
}

resource "azurerm_storage_queue" "this" {
  for_each = {
    for queue in local.storage_queues :
    "${queue.storage_account_key}-${queue.queue_key}" => queue
  }

  name                 = each.value.queue_key
  storage_account_name = azurerm_storage_account.this[each.value.storage_account_key].name
  metadata             = each.value.metadata
}

# Tables
locals {
  # Flatten storage accounts with their tables
  storage_tables = flatten([
    for sa_key, sa_value in var.storage_accounts : [
      for table_key, table_value in sa_value.tables : {
        storage_account_key = sa_key
        table_key           = table_key
        metadata            = table_value.metadata
      }
    ]
  ])
}

resource "azurerm_storage_table" "this" {
  for_each = {
    for table in local.storage_tables :
    "${table.storage_account_key}-${table.table_key}" => table
  }

  name                 = each.value.table_key
  storage_account_name = azurerm_storage_account.this[each.value.storage_account_key].name
}

# Lifecycle Management Policies
locals {
  # Create a map of storage accounts that have lifecycle rules
  storage_accounts_with_lifecycle = {
    for sa_key, sa_value in var.storage_accounts :
    sa_key => sa_value if length(sa_value.lifecycle_rules) > 0
  }
}

resource "azurerm_storage_management_policy" "this" {
  for_each = local.storage_accounts_with_lifecycle

  storage_account_id = azurerm_storage_account.this[each.key].id

  dynamic "rule" {
    for_each = each.value.lifecycle_rules
    content {
      name    = rule.value.name
      enabled = rule.value.enabled

      filters {
        blob_types = rule.value.blob_types
      }

      actions {
        dynamic "base_blob" {
          for_each = rule.value.base_blob != null ? [rule.value.base_blob] : []
          content {
            tier_to_cool_after_days_since_modification_greater_than    = base_blob.value.tier_to_cool_after_days
            tier_to_archive_after_days_since_modification_greater_than = base_blob.value.tier_to_archive_after_days
            delete_after_days_since_modification_greater_than          = base_blob.value.delete_after_days
          }
        }

        dynamic "snapshot" {
          for_each = rule.value.snapshot != null ? [rule.value.snapshot] : []
          content {
            change_tier_to_cool_after_days_since_creation    = snapshot.value.tier_to_cool_after_days
            change_tier_to_archive_after_days_since_creation = snapshot.value.tier_to_archive_after_days
            delete_after_days_since_creation_greater_than    = snapshot.value.delete_after_days
          }
        }

        dynamic "version" {
          for_each = rule.value.version != null ? [rule.value.version] : []
          content {
            change_tier_to_cool_after_days_since_creation    = version.value.tier_to_cool_after_days
            change_tier_to_archive_after_days_since_creation = version.value.tier_to_archive_after_days
            delete_after_days_since_creation                 = version.value.delete_after_days
          }
        }
      }
    }
  }
}

# Private Endpoints
locals {
  # Flatten private endpoints for all storage accounts
  private_endpoints = flatten([
    for sa_key, sa_value in var.storage_accounts : [
      for pe_key, pe_value in sa_value.private_endpoints : {
        storage_account_key             = sa_key
        private_endpoint_key            = pe_key
        subnet_id                       = pe_value.subnet_id
        private_dns_zone_group_name     = pe_value.private_dns_zone_group_name
        private_dns_zone_ids            = pe_value.private_dns_zone_ids
        subresource_names               = pe_value.subresource_names
        private_service_connection_name = pe_value.private_service_connection_name
        is_manual_connection            = pe_value.is_manual_connection
        request_message                 = pe_value.request_message
        tags                            = pe_value.tags
        location                        = sa_value.location
        resource_group_name             = sa_value.resource_group_name
      }
    ]
  ])
}

resource "azurerm_private_endpoint" "this" {
  for_each = {
    for pe in local.private_endpoints :
    "${pe.storage_account_key}-${pe.private_endpoint_key}" => pe
  }

  name                = "${each.value.private_endpoint_key}-pe"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  subnet_id           = each.value.subnet_id

  private_service_connection {
    name = coalesce(
      each.value.private_service_connection_name,
      "${each.value.private_endpoint_key}-psc"
    )
    private_connection_resource_id = azurerm_storage_account.this[each.value.storage_account_key].id
    subresource_names              = each.value.subresource_names
    is_manual_connection           = each.value.is_manual_connection
    request_message                = each.value.is_manual_connection ? each.value.request_message : null
  }

  dynamic "private_dns_zone_group" {
    for_each = length(each.value.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = each.value.private_dns_zone_group_name
      private_dns_zone_ids = each.value.private_dns_zone_ids
    }
  }

  tags = each.value.tags

  depends_on = [azurerm_storage_account.this]
} 