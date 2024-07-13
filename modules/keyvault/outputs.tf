output "keyvault" {
  value = { for k, v in azurerm_key_vault.kv : k => v}
  description = "values of the keyvault"
}