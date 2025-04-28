variable "resource_groups" {
  description = "Map of resource groups to create, with their respective subscription IDs"
  type = map(object({
    subscription_id = string
    rg_location    = string
    rg_tags        = map(string)
  }))
} 