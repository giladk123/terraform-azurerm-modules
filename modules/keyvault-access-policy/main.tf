resource "azurerm_key_vault_access_policy" "access_policy" {
  for_each = var.access_policies

  key_vault_id            = each.value.key_vault_id
  tenant_id               = each.value.tenant_id
  object_id               = each.value.object_id
  application_id          = each.value.application_id
  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions
  certificate_permissions = each.value.certificate_permissions
}