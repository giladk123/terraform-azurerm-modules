output "app_service_names" {
  description = "Names of all created app services"
  value       = module.app_services.app_service_names
}

output "app_service_urls" {
  description = "URLs of all created app services"
  value       = module.app_services.app_service_urls
}

output "app_service_identities" {
  description = "Managed identity principal IDs of all created app services"
  value       = module.app_services.app_service_identities
} 