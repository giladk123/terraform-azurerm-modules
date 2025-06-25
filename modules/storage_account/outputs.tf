output "storage_accounts" {
  description = "Map of all created storage accounts with their properties"
  value = {
    for key, sa in azurerm_storage_account.this : key => {
      id                        = sa.id
      name                      = sa.name
      primary_location          = sa.primary_location
      secondary_location        = sa.secondary_location
      primary_blob_endpoint     = sa.primary_blob_endpoint
      secondary_blob_endpoint   = sa.secondary_blob_endpoint
      primary_queue_endpoint    = sa.primary_queue_endpoint
      secondary_queue_endpoint  = sa.secondary_queue_endpoint
      primary_table_endpoint    = sa.primary_table_endpoint
      secondary_table_endpoint  = sa.secondary_table_endpoint
      primary_file_endpoint     = sa.primary_file_endpoint
      secondary_file_endpoint   = sa.secondary_file_endpoint
      primary_web_endpoint      = sa.primary_web_endpoint
      secondary_web_endpoint    = sa.secondary_web_endpoint
      primary_blob_host         = sa.primary_blob_host
      secondary_blob_host       = sa.secondary_blob_host
      primary_queue_host        = sa.primary_queue_host
      secondary_queue_host      = sa.secondary_queue_host
      primary_table_host        = sa.primary_table_host
      secondary_table_host      = sa.secondary_table_host
      primary_file_host         = sa.primary_file_host
      secondary_file_host       = sa.secondary_file_host
      primary_web_host          = sa.primary_web_host
      secondary_web_host        = sa.secondary_web_host
      primary_access_key        = sa.primary_access_key
      secondary_access_key      = sa.secondary_access_key
      primary_connection_string = sa.primary_connection_string
      secondary_connection_string = sa.secondary_connection_string
      primary_blob_connection_string = sa.primary_blob_connection_string
      secondary_blob_connection_string = sa.secondary_blob_connection_string
    }
  }
  sensitive = true
}

output "storage_account_ids" {
  description = "Map of storage account names to their resource IDs"
  value = {
    for key, sa in azurerm_storage_account.this : key => sa.id
  }
}

output "storage_account_names" {
  description = "Map of storage account keys to their actual names"
  value = {
    for key, sa in azurerm_storage_account.this : key => sa.name
  }
}

output "primary_blob_endpoints" {
  description = "Map of storage account names to their primary blob endpoints"
  value = {
    for key, sa in azurerm_storage_account.this : key => sa.primary_blob_endpoint
  }
}

output "primary_connection_strings" {
  description = "Map of storage account names to their primary connection strings"
  value = {
    for key, sa in azurerm_storage_account.this : key => sa.primary_connection_string
  }
  sensitive = true
}

output "containers" {
  description = "Map of all created storage containers"
  value = {
    for key, container in azurerm_storage_container.this : key => {
      id                   = container.id
      name                 = container.name
      storage_account_name = container.storage_account_name
      container_access_type = container.container_access_type
      resource_manager_id  = container.resource_manager_id
    }
  }
}

output "file_shares" {
  description = "Map of all created file shares"
  value = {
    for key, share in azurerm_storage_share.this : key => {
      id                   = share.id
      name                 = share.name
      storage_account_name = share.storage_account_name
      quota                = share.quota
      access_tier          = share.access_tier
      url                  = share.url
      resource_manager_id  = share.resource_manager_id
    }
  }
}

output "queues" {
  description = "Map of all created storage queues"
  value = {
    for key, queue in azurerm_storage_queue.this : key => {
      id                   = queue.id
      name                 = queue.name
      storage_account_name = queue.storage_account_name
      resource_manager_id  = queue.resource_manager_id
    }
  }
}

output "tables" {
  description = "Map of all created storage tables"
  value = {
    for key, table in azurerm_storage_table.this : key => {
      id                   = table.id
      name                 = table.name
      storage_account_name = table.storage_account_name
    }
  }
} 