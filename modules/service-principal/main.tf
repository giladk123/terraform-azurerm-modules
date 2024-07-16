data "azuread_client_config" "current" {}

data "azuread_user" "owner" {
  for_each            = { for sp in var.service_principals : sp.name => sp }
  user_principal_name = each.value.owner_username
}

locals {
  app_owner = {
    for sp in var.service_principals : sp.name => [
      data.azuread_client_config.current.object_id,
      data.azuread_user.owner[sp.name].object_id
    ]
  }
}

resource "azuread_application" "sp" {
  for_each     = { for sp in var.service_principals : sp.name => sp }
  display_name = each.value.name
  owners       = local.app_owner[each.key]
}

resource "azuread_service_principal" "sp" {
  for_each                     = { for sp in var.service_principals : sp.name => sp }
  application_id               = azuread_application.sp[each.key].application_id
  app_role_assignment_required = false
  owners                       = local.app_owner[each.key]
}

resource "time_rotating" "year" {
  for_each      = { for sp in var.service_principals : sp.name => sp }
  rotation_days = each.value.secret_rotation_days
}

resource "azuread_service_principal_password" "application" {
  for_each = { for sp in var.service_principals : sp.name => sp }
  #display_name         = each.value.app_password_name
  service_principal_id = azuread_service_principal.sp[each.key].object_id
  rotate_when_changed = {
    rotation = time_rotating.year[each.key].id
  }
}

resource "azuread_application_password" "app" {
  for_each              = { for sp in var.service_principals : sp.name => sp }
  display_name          = each.value.client_secret_name
  application_object_id = azuread_application.sp[each.key].object_id
}

resource "azurerm_role_assignment" "assignments" {
  for_each             = { for assignment in var.assignments : assignment.sp_name => assignment }
  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = azuread_service_principal.sp[each.key].object_id
}
