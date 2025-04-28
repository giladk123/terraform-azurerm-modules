locals {
  resource_groups = var.resource_groups
  unique_subscriptions = distinct([for rg in local.resource_groups : rg.subscription_id])
}

# Create resource groups with their respective subscription IDs
resource "azurerm_resource_group" "this" {
  for_each = local.resource_groups

  name     = "rg-${var.name_convention.region}-${var.name_convention.dbank_idbank_first_letter}-${var.name_convention.env}-${var.name_convention.cmdb_infra}-${var.name_convention.cmdb_project}-${each.key}"
  location = each.value.rg_location
  tags     = each.value.rg_tags

  provider = azurerm.aliases
} 