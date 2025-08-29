### ubuntu-postgresql

Creates an Ubuntu VM (24.04 LTS) and installs PostgreSQL (defaults to 16.7) configured for LDAP authentication against AD.

Resources used
- `azurerm_public_ip` (optional)
- `azurerm_network_interface`
- `azurerm_linux_virtual_machine`

Inputs
- `name_convention` (object)
- `vm` (object): resource_group, location, size, admin_username, ssh_public_key, subnet_id, private_ip_address?, create_public_ip?, public_ip_allocation_method?, tags?
- `postgres` (object): version?, db_name?, db_owner?, db_owner_password?, listen_addresses?, port?
- `ldap` (object): domain_fqdn, bind_dn, bind_password, search_base, server_host
- `nsg` (object|null): name?, security_rules?[] — attach an NSG to the NIC

Important
- The bootstrap installs the official PGDG apt repo to fetch requested versions.
- Ensure network security rules allow TCP 5432 to your clients.

Example
```hcl
module "postgres" {
  source = "../..//modules/ubuntu-postgresql"
  name_convention = local.cfg.name_convention
  vm = {
    resource_group = local.rg_name
    location       = local.cfg.resource_group.location
    size           = "Standard_B2s"
    admin_username = "azureadmin"
    ssh_public_key = file("~/.ssh/id_rsa.pub")
    subnet_id      = module.vnet.subnet_ids["main-pg"]
  }
  postgres = {
    version = "16.7"
    db_name = "appdb"
    db_owner = "appowner"
    db_owner_password = var.db_owner_password
  }
  ldap = {
    domain_fqdn   = module.ad.domain_fqdn
    bind_dn       = module.ad.ldap_bind_dn
    bind_password = var.bind_password
    search_base   = "DC=corp,DC=contoso,DC=local"
    server_host   = module.ad.private_ip
  }
  nsg = {
    name = "${local.name_prefix}-pg-nsg"
    security_rules = [
      {
        name                       = "allow-pg"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }
}
```


