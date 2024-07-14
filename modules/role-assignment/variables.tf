variable "azure_rbac" {
  type = list(object({
    key          = string
    scope        = string
    principal_id = string
    role         = string
  }))
  description = "List of objects with parameters to create role assignment"
}
