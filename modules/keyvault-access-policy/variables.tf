variable "access_policies" {
  description = "Access policies to apply to the key vault"
  type = map(object({
    key_vault_id = string
    tenant_id    = string
    #object_id = string
    object_id               = optional(string)
    application_id          = optional(string)
    key_permissions         = list(string)
    secret_permissions      = list(string)
    certificate_permissions = list(string)
  }))
}