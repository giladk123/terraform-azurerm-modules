locals {
  resource_groups = var.resource_groups
}

# Create resource groups
resource "azurerm_resource_group" "this" {
  for_each = local.resource_groups

  name     = "${each.value.name_convention.region}-${each.value.name_convention.dbank_idbank_first_letter}${each.value.name_convention.env}-${each.value.name_convention.cmdb_infra}-${each.value.name_convention.cmdb_project}-${each.key}-rg"
  location = each.value.rg_location
  tags     = each.value.rg_tags
} 