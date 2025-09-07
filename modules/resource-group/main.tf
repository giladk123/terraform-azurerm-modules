terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
  }
}

resource "azurerm_resource_group" "rg" {
  for_each = var.resource_groups

  name     = "${local.name_prefix}-${each.key}-rg"
  location = each.value.rg_location
  tags     = each.value.rg_tags
}