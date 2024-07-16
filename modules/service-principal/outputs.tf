output "sp_client_secret" {
  value       = { for key, app in azuread_service_principal_password.application : key => app.value }
  description = "The client secret for the Azure AD Service Principal."
  sensitive   = true
}

output "app_registration_client_secret" {
  value       = { for key, app in azuread_application_password.app : key => app.value }
  description = "The client secret for the Azure AD Application."
  sensitive   = true
}

output "app_registration_object_id" {
  value       = { for key, app in azuread_application.sp : key => app.object_id }
  description = "The object IDs of the Azure AD applications."
}

output "app_registration_application_id" {
  value       = { for key, app in azuread_application.sp : key => app.application_id }
  description = "The application IDs of the Azure AD applications"
}

output "sp_object_id" {
  value       = { for key, sp in azuread_service_principal.sp : key => sp.object_id }
  description = "The object IDs of the Azure AD service principals."
}

output "sp_application_id" {
  value       = { for key, sp in azuread_service_principal.sp : key => sp.application_id }
  description = "The application IDs of the Azure AD service principals"
}