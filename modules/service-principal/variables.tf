variable "service_principals" {
  description = "The service principals"
  type = list(object({
    name           = string
    owner_username = string
    #app_password_name    = string
    client_secret_name   = string
    secret_rotation_days = number
  }))
}

variable "assignments" {
  description = "List of role assignments"
  type = list(object({
    sp_name              = string
    scope                = string
    role_definition_name = string
  }))
}