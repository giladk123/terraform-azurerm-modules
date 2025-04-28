locals {
  resource_groups = var.resource_groups
  unique_subscriptions = distinct([for rg in local.resource_groups : rg.subscription_id])
}

# Create resource groups with their respective subscription IDs
resource "azurerm_resource_group" "this" {
  for_each = local.resource_groups

  name     = "rg-${each.value.name_convention.region}-${each.value.name_convention.dbank_idbank_first_letter}-${each.value.name_convention.env}-${each.value.name_convention.cmdb_infra}-${each.value.name_convention.cmdb_project}-${each.key}"
  location = each.value.rg_location
  tags     = each.value.rg_tags

  provider = azurerm.aliases
} 