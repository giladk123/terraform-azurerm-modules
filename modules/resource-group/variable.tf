variable "resource_groups" {
  description = "Map of resource group details"
  type = map(object({
    rg_location = string
    rg_tags     = map(string)
  }))
}

variable "name_convention" {
  description = "Naming convention details."
  type = object({
    region                    = string
    dbank_idbank_first_letter = string
    env                       = string
    cmdb_infra                = string
    cmdb_project              = string
  })
}