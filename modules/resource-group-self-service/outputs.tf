output "resource_group_ids" {
  description = "The IDs of the created resource groups"
  value = {
    for name, rg in azurerm_resource_group.this : name => rg.id
  }
}

output "resource_group_locations" {
  description = "The locations of the created resource groups"
  value = {
    for name, rg in azurerm_resource_group.this : name => rg.location
  }
}

output "resource_group_tags" {
  description = "The tags of the created resource groups"
  value = {
    for name, rg in azurerm_resource_group.this : name => rg.tags
  }
}
