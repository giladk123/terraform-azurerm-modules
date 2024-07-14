resource "azurerm_role_assignment" "this" {
  for_each = {
    for permission in var.azure_rbac : "${permission.key}-${permission.role}" => permission
    if permission.key != null
  }

  scope                = each.value.scope
  role_definition_name = each.value.role
  principal_id         = each.value.principal_id
}
