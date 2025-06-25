# Example: Using the Storage Account Module

# Configure the Azure Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Load storage account configurations from JSON
locals {
  storage_accounts = jsondecode(file("${path.module}/storage-accounts.json"))
}

# Call the storage account module
module "storage_accounts" {
  source = "./modules/storage_account"
  
  storage_accounts = local.storage_accounts
}

# Example outputs to demonstrate accessing module outputs
output "all_storage_account_ids" {
  description = "All storage account resource IDs"
  value       = module.storage_accounts.storage_account_ids
}

output "production_storage_endpoint" {
  description = "Blob endpoint for production storage account"
  value       = module.storage_accounts.primary_blob_endpoints["stprodapp001"]
}

output "static_website_endpoint" {
  description = "Static website endpoint"
  value       = module.storage_accounts.storage_accounts["ststatic001"].primary_web_endpoint
}

output "all_containers" {
  description = "All created storage containers"
  value       = module.storage_accounts.containers
}

# Example of using connection string in another resource
# resource "azurerm_app_service" "example" {
#   # ... other configuration ...
#   
#   app_settings = {
#     "StorageConnectionString" = module.storage_accounts.primary_connection_strings["stprodapp001"]
#   }
# } 