output "private_endpoints" {
  description = "Map of all private endpoints"
  value       = { for pe in azurerm_private_endpoint.pe : pe.name => pe }
}
