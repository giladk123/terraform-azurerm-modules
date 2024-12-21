terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.81.0"
    }
  }
}

locals {
  subnet_details = flatten([
    for vnet, details in var.vnets : [
      for subnet in details.subnets : {
        vnet_name = vnet
        subnet    = subnet
      }
    ]
  ])
}

resource "azurerm_virtual_network" "vnet" {
  for_each            = var.vnets
  name                = "${local.name_prefix}-${each.key}-vnet"
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  address_space       = each.value.address_space
  tags                = each.value.tags
}

resource "azurerm_subnet" "subnet" {
  for_each             = { for item in local.subnet_details : "${item.vnet_name}-${item.subnet.name}" => item }
  name                 = each.value.subnet.name
  resource_group_name  = var.vnets[each.value.vnet_name].resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_name].name
  address_prefixes     = [each.value.subnet.address_prefix]
}