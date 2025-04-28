variable "resource_groups" {
  description = "Map of resource groups to create"
  type = map(object({
    subscription_id = string
    rg_location    = string
    rg_tags       = map(string)
  }))
}

variable "name_convention" {
  description = "Naming convention for resources"
  type = object({
    region                    = string
    dbank_idbank_first_letter = string
    env                      = string
    cmdb_infra               = string
    cmdb_project             = string
  })
} 