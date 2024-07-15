output "access_policies" {
  value = { for k, v in azurerm_key_vault_access_policy.access_policy : k => v}
  description = "value of the access policies applied to the key vault"
}