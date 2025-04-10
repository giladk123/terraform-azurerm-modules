resource "azurerm_virtual_network" "vnet" {
  for_each            = var.vnet_config
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  address_space       = each.value.address_space
}

resource "azurerm_subnet" "subnet" {
  for_each = {
    for subnet in flatten([
      for vnet_key, vnet in var.vnet_config : [
        for subnet_key, subnet in vnet.subnets : {
          id           = "${vnet_key}-${subnet_key}"
          vnet_key    = vnet_key
          subnet_key  = subnet_key
          subnet_config = subnet
          vnet_name   = azurerm_virtual_network.vnet[vnet_key].name
          rg_name     = vnet.resource_group_name
        }
      ]
    ]) : subnet.id => subnet
  }
  
  name                 = each.value.subnet_config.name
  resource_group_name  = each.value.rg_name
  virtual_network_name = each.value.vnet_name
  address_prefixes     = each.value.subnet_config.address_prefixes
}