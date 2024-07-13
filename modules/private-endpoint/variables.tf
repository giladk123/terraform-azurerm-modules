variable "endpoints" {
  description = "A map of endpoint configurations"
  type = map(object({
    name                           = string
    resource_group_name            = string
    subnet_id                      = string
    private_dns_zone_id            = string
    location                       = string
    private_connection_resource_id = string
    subresource_names              = list(string)
  }))
}