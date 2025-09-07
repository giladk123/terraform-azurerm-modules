variable "subscription_id" {
  description = "The subscription ID to use for the Azure provider"
  type        = string
}

variable "resource_groups" {
  description = "A map of resource group configurations"
  type = map(object({
    name_convention = object({
      region                    = string
      dbank_idbank_first_letter = string
      env                       = string
      cmdb_infra                = string
      cmdb_project              = string
    })
    rg_location = string
    rg_tags     = map(string)
  }))
}
