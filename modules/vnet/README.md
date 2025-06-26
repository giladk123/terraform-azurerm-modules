## Usage

```terraform

locals {
  vnet_settings           = jsondecode(file("./network/vnet.json"))
}

module "modules_vnet" {
  source  = "app.terraform.io/hcta-azure-dev/modules/azurerm//modules/vnet"
  version = "1.0.51"

  vnets = {
    for k, v in local.vnet_settings.vnets : k => merge(v, {
      resource_group_name = module.resource-group.resource_groups["testing"].name
    })
  }
  name_convention = local.vnet_settings.name_convention

}


```

Output Examples

```terraform
# Subnet outputs
output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value = {
    for k, v in module.modules_vnet.subnet : k => v.id
    if startswith(k, "testing-")
  }
}

output "subnet_names" {
  description = "Map of subnet keys to their names"
  value = {
    for k, v in module.modules_vnet.subnet : k => v.name
    if startswith(k, "testing-")
  }
}

output "subnet_address_prefixes" {
  description = "Map of subnet names to their address prefixes"
  value = {
    for k, v in module.modules_vnet.subnet : k => v.address_prefixes
    if startswith(k, "testing-")
  }
}

# All resources output
output "all_vnets" {
  description = "All virtual networks managed by this module"
  value       = module.modules_vnet.vnet
}

output "all_subnets" {
  description = "All subnets managed by this module"
  value       = module.modules_vnet.subnet
}

```

JSON Example

```json
{
    "vnets": {
        "testing": {
            "resource_group_name": "will-be-overridden-by-terraform",
            "location": "westeurope",
            "address_space": ["10.62.252.0/24"],
            "tags": {"environment": "dev"},
            "subnets": [
                {"name": "subnet-001", "address_prefix": "10.62.252.0/28"},
                {"name": "subnet-002", "address_prefix": "10.62.252.16/28"}
            ]
        }
    },
    "name_convention": {
        "region": "we",
        "dbank_idbank_first_letter": "i",
        "env": "dev",
        "cmdb_infra": "aznt",
        "cmdb_project": "abcd"
    }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.104.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.104.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vnets"></a> [vnets](#input\_vnets) | n/a | `map(any)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnet"></a> [subnet](#output\_subnet) | All subnets |
| <a name="output_vnet"></a> [vnet](#output\_vnet) | All virtual networks |
