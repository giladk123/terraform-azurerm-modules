### windows-ad-domain-controller

Creates a Windows Server 2025 VM and configures Active Directory Domain Services (AD DS). Optionally creates a domain user for LDAP binds.

Resources used
- `azurerm_public_ip` (optional)
- `azurerm_network_interface`
- `azurerm_windows_virtual_machine`
- `azurerm_virtual_machine_extension` (Custom Script)

Inputs
- `name_convention` (object): region, idbank initial, env, cmdb_infra, cmdb_project
- `vm` (object): resource_group, location, size, admin_username, admin_password, subnet_id, private_ip_address?, create_public_ip?, public_ip_allocation_method?, tags?
- `domain` (object): domain_fqdn, netbios_name, safe_mode_password, site_name?
- `ldap_user` (object|null): create?, username?, password?, ou_dn?, given_name?, surname?
- `nsg` (object|null): name?, security_rules?[] — attach an NSG to the NIC

Outputs
- `vm_id`: Domain controller VM ID
- `private_ip`: DC private IP
- `domain_fqdn`: Domain FQDN
- `ldap_bind_dn`: DN for created bind user (or null)

Example
```hcl
module "ad" {
  source = "../..//modules/windows-ad-domain-controller"
  name_convention = local.cfg.name_convention
  vm = {
    resource_group = local.rg_name
    location       = local.cfg.resource_group.location
    size           = "Standard_B2ms"
    admin_username = "azureadmin"
    admin_password = var.admin_password
    subnet_id      = module.vnet.subnet_ids["main-ad"]
  }
  domain = {
    domain_fqdn        = "corp.contoso.local"
    netbios_name       = "CORP"
    safe_mode_password = var.safe_mode_password
  }
  ldap_user = {
    create     = true
    username   = "pgbind"
    password   = var.bind_password
    ou_dn      = "CN=Users"
    given_name = "PG"
    surname    = "Bind"
  }
  nsg = {
    name = "${local.name_prefix}-dc-nsg"
    security_rules = [
      {
        name                       = "allow-rdp"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "allow-ldap"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }
}
```


