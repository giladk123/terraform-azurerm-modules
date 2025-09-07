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

variable "vm" {
  description = "Ubuntu VM configuration for PostgreSQL."
  type = object({
    resource_group              = string
    location                    = string
    size                        = string
    admin_username              = string
    ssh_public_key              = string
    subnet_id                   = string
    private_ip_address          = optional(string)
    create_public_ip            = optional(bool, false)
    public_ip_allocation_method = optional(string, "Dynamic")
    tags                        = optional(map(string), {})
  })
}

variable "postgres" {
  description = "PostgreSQL configuration."
  type = object({
    version           = optional(string, "16")
    db_name           = optional(string, "appdb")
    db_owner          = optional(string, "appowner")
    db_owner_password = optional(string)
    listen_addresses  = optional(string, "*")
    port              = optional(number, 5432)
  })
}

variable "ldap" {
  description = "LDAP settings for PostgreSQL to authenticate against AD."
  type = object({
    domain_fqdn   = string
    bind_dn       = string
    bind_password = string
    search_base   = string
    server_host   = string
  })
}

variable "nsg" {
  description = "Optional NSG configuration to attach to the NIC."
  type = object({
    name = optional(string)
    security_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string)
      destination_port_range     = optional(string)
      source_address_prefix      = optional(string)
      destination_address_prefix = optional(string)
    })), [])
  })
  default = null
}


