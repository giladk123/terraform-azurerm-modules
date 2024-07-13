## Usage

```terraform
locals {
  resource_group = jsondecode(file("<path to json file/><resource-group.json>"))
}

module "resource_group" {
  source = "./module/rg"

  resource_groups = local.resource_group.resource_groups

}
```

## Example of JSON 

```json
{
    "resource_groups": {
        "<resource group name>": {
            "rg_location": "West Europe",
            "rg_tags": {
                "environment": "<dev/uat/prd>"
            }
        },
        "<resource group mame>": {
            "rg_location": "West Europe",
            "rg_tags": {
                "environment": "<dev/uat/prd>"
            }
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
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | Map of resource group details | <pre>map(object({<br>    rg_location = string<br>    rg_tags     = map(string)<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_groups"></a> [resource\_groups](#output\_resource\_groups) | All resource groups |
