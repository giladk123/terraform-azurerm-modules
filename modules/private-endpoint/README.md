## Usage

```terraform
module "private-endpoint" {
  source = "./module/private-endpoint"

  endpoints = {
    "keyvault-endpoint": {
      "name": "<private endpoint name>-pe",
      "resource_group_name": module.resource_group.resource_groups["<resource group name>"].name,
      "subnet_id": module.vnet.subnet["<vnet name>-<subnet name>"].id,
      "private_dns_zone_id": module.private_dns_zones.dns_zone_ids["privatelink.vaultcore.azure.net"],
      "location": "westeurope",
      "private_connection_resource_id": module.keyvault.keyvault["keyvault name"].id,
      "subresource_names": ["vault"]
    }
  }
  
  depends_on = [ module.vnet, module.private_dns_zones, module.resource_group]
}
```

Output Examples

```terraform
output "private_endpoint_name_and_id" {
    description = "Specific private endpoint"
    value = {
        name = module.private-endpoint.private_endpoints["<private endpoint name>"].name
        id = module.private-endpoint.private_endpoints["<private endpoint name>"].id
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
| [azurerm_private_endpoint.pe](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_endpoints"></a> [endpoints](#input\_endpoints) | A map of endpoint configurations | <pre>map(object({<br>    name                           = string<br>    resource_group_name            = string<br>    subnet_id                      = string<br>    private_dns_zone_id            = string<br>    location                       = string<br>    private_connection_resource_id = string<br>    subresource_names              = list(string)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_endpoints"></a> [private\_endpoints](#output\_private\_endpoints) | Map of all private endpoints |
