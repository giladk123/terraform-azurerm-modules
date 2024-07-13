output "dns_zone_ids" {
    description = "The IDs of the created DNS zones"
    value       = { for zone in azurerm_private_dns_zone.private_dns : zone.name => zone.id }
}