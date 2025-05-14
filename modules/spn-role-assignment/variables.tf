variable "service_principals" {
  description = "Map of service principals and their role assignments"
  type = map(object({
    object_id = string
    role_assignments = map(object({
      scope                = string
      role_definition_name = string
      description          = optional(string)
      skip_service_principal_aad_check = optional(bool, false)
    }))
  }))
}
