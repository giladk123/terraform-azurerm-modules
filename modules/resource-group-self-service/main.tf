terraform {
  required_version = ">=1.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">3.11.0"
    }
  }
}

locals {
  resource_groups = var.resource_groups
  unique_subscriptions = distinct([for rg in local.resource_groups : rg.value.subscription_id])
}

# Create resource groups with their respective subscription IDs
resource "azurerm_resource_group" "this" {
  for_each = local.resource_groups

  name     = each.key
  location = each.value.rg_location
  tags     = each.value.rg_tags

  provider = azurerm
} 