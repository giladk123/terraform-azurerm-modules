# Storage Account Module Example
# This example demonstrates how to use the storage account module with various configurations

# Load storage account configurations from JSON
locals {
  storage_accounts = jsondecode(file("${path.module}/storage-accounts.json"))
}

# Create resource groups for the storage accounts
resource "azurerm_resource_group" "storage_prod" {
  name     = "rg-storage-prod-001"
  location = "eastus"
}

resource "azurerm_resource_group" "storage_dev" {
  name     = "rg-storage-dev-001"
  location = "westus2"
}

resource "azurerm_resource_group" "web_prod" {
  name     = "rg-web-prod-001"
  location = "eastus"
}

# Deploy storage accounts using the module
module "storage_accounts" {
  source = "../../modules/storage_account"
  
  storage_accounts = local.storage_accounts
  
  depends_on = [
    azurerm_resource_group.storage_prod,
    azurerm_resource_group.storage_dev,
    azurerm_resource_group.web_prod
  ]
} 