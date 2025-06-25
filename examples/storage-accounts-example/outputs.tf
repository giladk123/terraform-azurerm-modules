# Storage Account IDs
output "storage_account_ids" {
  description = "Map of all storage account IDs"
  value       = module.storage_accounts.storage_account_ids
}

# Storage Account Names
output "storage_account_names" {
  description = "Map of storage account names"
  value       = module.storage_accounts.storage_account_names
}

# Blob Endpoints
output "blob_endpoints" {
  description = "Primary blob endpoints for all storage accounts"
  value       = module.storage_accounts.primary_blob_endpoints
}

# Specific outputs for demonstration
output "production_app_storage" {
  description = "Production application storage account details"
  value = {
    id               = module.storage_accounts.storage_account_ids["stprodapp001"]
    name             = module.storage_accounts.storage_account_names["stprodapp001"]
    blob_endpoint    = module.storage_accounts.primary_blob_endpoints["stprodapp001"]
    containers       = [for k, v in module.storage_accounts.containers : v.name if startswith(k, "stprodapp001")]
  }
}

output "static_website_url" {
  description = "Static website URL"
  value       = try(module.storage_accounts.storage_accounts["ststatic001"].primary_web_endpoint, "Not configured")
}

output "data_lake_storage" {
  description = "Data Lake storage account details"
  value = {
    id            = module.storage_accounts.storage_account_ids["stdevdata001"]
    name          = module.storage_accounts.storage_account_names["stdevdata001"]
    is_hns_enabled = true
  }
}

# File share details
output "file_shares" {
  description = "All created file shares"
  value       = module.storage_accounts.file_shares
}

# Connection string example (marked as sensitive)
output "example_connection_string" {
  description = "Example connection string for stprodapp001 (sensitive)"
  value       = module.storage_accounts.primary_connection_strings["stprodapp001"]
  sensitive   = true
} 