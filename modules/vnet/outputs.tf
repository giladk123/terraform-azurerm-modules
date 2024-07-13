output "vnet" {
  description = "All virtual networks"
  value       = azurerm_virtual_network.vnet
}

output "subnet" {
  description = "All subnets"
  value       = azurerm_subnet.subnet
}