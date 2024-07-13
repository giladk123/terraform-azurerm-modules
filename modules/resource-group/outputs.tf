output "resource_groups" {
  description = "shows All resource groups created in the subscription"
  value       = { for k, v in azurerm_resource_group.rg : k => v }
}