resource "azurerm_key_vault" "kv" {
  for_each = var.keyvaults

  name                          = each.key
  location                      = each.value.location
  resource_group_name           = each.value.resource_group_name
  tenant_id                     = each.value.tenant_id
  soft_delete_retention_days    = 30
  purge_protection_enabled      = true
  sku_name                      = each.value.sku_name
  public_network_access_enabled = each.value.public_network_access_enabled
}