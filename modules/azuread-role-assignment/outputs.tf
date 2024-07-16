# output "application_developer_role_id" {
#   value = lookup({ for role in data.azuread_directory_roles.available_roles.roles : role.display_name => role.object_id }, "Application Developer", null)
#   description = "The object ID of the Application Developer role in Azure AD."
# }

output "role_assignments_details" {
  value = {
    for key, assgn in azuread_directory_role_assignment.role_assignment :
    key => {
      role_id             = assgn.role_id
      principal_object_id = assgn.principal_object_id
    }
  }
  description = "A map of Azure AD role assignments including role IDs and principal object IDs."
}

