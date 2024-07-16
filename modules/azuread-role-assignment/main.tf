data "azuread_directory_roles" "available_roles" {}

locals {
  # Flatten the roles_assignments to create a combination of each role_name with each principal_object_id
  flattened_assignments = flatten([
    for assignment in var.roles_assignments : [
      for role_name in assignment.role_names : [
        for principal_object_id in assignment.principal_object_ids : {
          role_name           = role_name,
          principal_object_id = principal_object_id
        }
      ]
    ]
  ])

  # Filter the flattened assignments to include only those where the role name exists in the available Azure AD roles
  filtered_assignments = [
    for assgn in local.flattened_assignments :
    assgn if contains([for role in data.azuread_directory_roles.available_roles.roles : role.display_name], assgn.role_name)
  ]
}

resource "azuread_directory_role_assignment" "role_assignment" {
  for_each = {
    for idx, assgn in local.filtered_assignments :
    "${idx}-${assgn.role_name}-${assgn.principal_object_id}" => assgn
  }

  # Fetch the role_id by matching the role_name with available roles and extracting the object_id
  role_id = tolist([
    for role in data.azuread_directory_roles.available_roles.roles :
    role.object_id if role.display_name == each.value.role_name
  ])[0]
  principal_object_id = each.value.principal_object_id
}