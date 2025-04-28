variable "resource_groups" {
  description = "Map of resource groups to create"
  type = map(object({
    rg_location    = string
    rg_tags       = map(string)
    name_convention = object({
      region                    = string
      dbank_idbank_first_letter = string
      env                      = string
      cmdb_infra               = string
      cmdb_project             = string
    })
  }))
} 