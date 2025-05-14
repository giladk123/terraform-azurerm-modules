data "azurerm_role_definition" "role_definition" {
  for_each = {
    for assignment in flatten([
      for sp_key, sp in var.service_principals : [
        for assignment_key, assignment in sp.role_assignments : {
          sp_key = sp_key
          assignment_key = assignment_key
          role_definition_name = assignment.role_definition_name
        }
      ]
    ]) : "${assignment.sp_key}.${assignment.assignment_key}" => assignment.role_definition_name
  }
  name = each.value
}

resource "azurerm_role_assignment" "spn_role_assignment" {
  for_each = {
    for assignment in flatten([
      for sp_key, sp in var.service_principals : [
        for assignment_key, assignment in sp.role_assignments : {
          sp_key = sp_key
          assignment_key = assignment_key
          scope = assignment.scope
          role_definition_id = data.azurerm_role_definition.role_definition["${sp_key}.${assignment_key}"].id
          description = lookup(assignment, "description", null)
          skip_service_principal_aad_check = lookup(assignment, "skip_service_principal_aad_check", false)
          principal_id = sp.object_id
        }
      ]
    ]) : "${assignment.sp_key}.${assignment.assignment_key}" => assignment
  }

  scope                = each.value.scope
  role_definition_id   = each.value.role_definition_id
  principal_id         = each.value.principal_id
  description          = each.value.description
  skip_service_principal_aad_check = each.value.skip_service_principal_aad_check
}
