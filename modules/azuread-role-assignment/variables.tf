variable "roles_assignments" {
  description = "A list of role assignments"
  type = list(object({
    role_names           = list(string)
    principal_object_ids = list(string)
  }))
}