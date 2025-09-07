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
  description = "Windows VM configuration for domain controller."
  type = object({
    resource_group              = string
    location                    = string
    size                        = string
    admin_username              = string
    admin_password              = string
    subnet_id                   = string
    computer_name               = optional(string)
    private_ip_address          = optional(string)
    create_public_ip            = optional(bool, false)
    public_ip_allocation_method = optional(string, "Dynamic")
    tags                        = optional(map(string), {})
  })
}

variable "domain" {
  description = "Active Directory domain settings."
  type = object({
    domain_fqdn        = string
    netbios_name       = string
    safe_mode_password = string
    site_name          = optional(string, "Default-First-Site-Name")
  })
  validation {
    condition     = length(trimspace(var.domain.safe_mode_password)) > 0
    error_message = "domain.safe_mode_password must be non-empty."
  }
}

variable "ldap_user" {
  description = "Optional LDAP user to create in the domain."
  type = object({
    create     = optional(bool, false)
    username   = optional(string)
    password   = optional(string)
    ou_dn      = optional(string, "CN=Users")
    given_name = optional(string)
    surname    = optional(string)
  })
  default = null
}

variable "nsg" {
  description = "Optional NSG configuration to attach to the NIC."
  type = object({
    name = optional(string)
    security_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string # Inbound/Outbound
      access                     = string # Allow/Deny
      protocol                   = string # Tcp/Udp/Asterisk
      source_port_range          = optional(string)
      destination_port_range     = optional(string)
      source_address_prefix      = optional(string)
      destination_address_prefix = optional(string)
    })), [])
  })
  default = null
}


