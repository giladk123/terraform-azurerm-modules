variable "vms" {
  description = "Map of virtual machine configurations."
  type = map(object({
    resource_group              = string
    location                    = string
    size                        = string
    ssh_public_key              = string
    admin_username              = string
    image_offer                 = string
    image_publisher             = string
    image_sku                   = string
    image_version               = string
    subnet_id                   = string
    network_security_group_name = optional(string)
    security_rules              = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    })), [])
    private_ip_address          = optional(string)
    create_public_ip            = optional(bool, false)
    public_ip_allocation_method = optional(string, "Dynamic")
    public_ip_dns_name          = optional(string)
    tags                        = optional(map(string), {})
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