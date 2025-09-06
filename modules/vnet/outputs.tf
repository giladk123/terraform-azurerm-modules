output "vnet" {
  description = "All virtual networks"
  value       = azurerm_virtual_network.vnet
}

output "vnets" {
  description = "All virtual networks (alias for compatibility)"
  value       = azurerm_virtual_network.vnet
}

output "subnet" {
  description = "All subnets"
  value       = azurerm_subnet.subnet
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = {
    for key, subnet in azurerm_subnet.subnet : key => subnet.id
  }
}