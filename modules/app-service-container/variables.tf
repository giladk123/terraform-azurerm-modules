variable "app_services" {
  description = "Map of app services to create"
  type = map(object({
    name                                    = string
    resource_group_name                     = string
    location                                = string
    sku_name                                = string
    docker_image                            = string
    docker_image_tag                        = string
    docker_registry_server_url              = optional(string)
    always_on                               = optional(bool)
    container_registry_use_managed_identity = optional(bool)
    app_settings                            = optional(map(string))
    tags                                    = optional(map(string))
  }))
} 
