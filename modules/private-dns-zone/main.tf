terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.81.0"
    }
  }
}

resource "azurerm_private_dns_zone" "private_dns" {
  for_each = toset(var.zones)

  name                = each.key
  resource_group_name = var.resource_group_name
}