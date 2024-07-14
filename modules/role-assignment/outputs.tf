output "role_assignments" {
  description = "All of the role assignments"
  value       = { for key, ra in azurerm_role_assignment.this : key => ra }
}