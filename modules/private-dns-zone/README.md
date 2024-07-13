## Usage

```terraform
module "private-dns-zone" {
  source = "./modules/private-dns-zone"

  zones = var.zones
  resource_group_name = var.resource_group_name
  
  depends_on = [ module.resource-group ]
}
```

json:

```json
{
    "zones": [
        "privatelink.blob.core.windows.net",
        "privatelink.queue.core.windows.net",
        "privatelink.table.core.windows.net",
        "privatelink.file.core.windows.net",
        "privatelink.vaultcore.azure.net",
        "privatelink.dfs.core.windows.net"
    ],
    "resource_group_name": "we-ydev-azus-opdx-arutzim-rg"
}
```

Outputs.tf :

```terraform
output "dns_zones" {
  description = "All DNS zones created in the subscription"
  value       = module.private-dns-zone.dns_zone_ids
}
```


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.81.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.81.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.private_dns](https://registry.terraform.io/providers/hashicorp/azurerm/3.81.0/docs/resources/private_dns_zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | A list of DNS zone names | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_zone_ids"></a> [dns\_zone\_ids](#output\_dns\_zone\_ids) | The IDs of the created DNS zones |
