output "role_assignment_ids" {
  description = "Map of role assignment names to their IDs"
  value       = { for k, v in azurerm_role_assignment.spn_role_assignment : k => v.id }
}
