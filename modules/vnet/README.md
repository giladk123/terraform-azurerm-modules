## Usage

```terraform

locals {
  vnet_settings           = jsondecode(file("./network/vnet.json"))
}


module "vnet" {
  source   = "./module/vnet"

  vnets = local.vnet_settings.vnets

}
```

Output Examples

```terraform

output "vnet_id" {
  value = module.vnet.vnet["<vnet name>"].id
}

output "subnet_id" {
  value = module.vnet.subnet["<vnet name>-<subnet name>"].id
}
```

JSON Example

```json
{
    "vnets": {
        "<vnet name>": {
            "resource_group_name": "<resource group name>",
            "location": "westeurope",
            "address_space": ["10.62.252.0/24"],
            "tags": {"environment": "dev"},
            "subnets": [
                {"name": "<subnet name>", "address_prefix": "10.62.252.0/28"},
                {"name": "<subnet name>", "address_prefix": "10.62.252.16/28"}
        ]
        },
        "<vnet name>": {
            "resource_group_name": "<resource group name>",
            "location": "westeurope",
            "address_space": ["10.62.253.0/24"],
            "tags": {"environment": "dev"},
            "subnets": [
                {"name": "<subnet name>", "address_prefix": "10.62.253.0/28"},
                {"name": "<subnet name>", "address_prefix": "10.62.253.16/28"}
        ]
        }
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
