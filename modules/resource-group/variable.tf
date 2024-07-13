variable "resource_groups" {
  description = "Map of resource group details"
  type = map(object({
    rg_location = string
    rg_tags     = map(string)
  }))
}