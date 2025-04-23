output "app_service_names" {
  description = "The names of the created app services"
  value       = { for k, v in azurerm_linux_web_app.app_service : k => v.name }
}

output "app_service_urls" {
  description = "The URLs of the created app services"
  value       = { for k, v in azurerm_linux_web_app.app_service : k => v.default_hostname }
}

output "app_service_identities" {
  description = "The managed identities of the created app services"
  value       = { for k, v in azurerm_linux_web_app.app_service : k => v.identity[0].principal_id }
} 