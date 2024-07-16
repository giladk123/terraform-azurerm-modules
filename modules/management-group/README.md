## Usage

```terraform

locals {
  management_group    = jsondecode(file("./ccoe/management-group.json"))
}

module "modules_management-group" {
  source  = "app.terraform.io/hcta-azure-dev/modules/azurerm//modules/management-group"
  version = "<version>"
  
  data = local.management_group
}
```

Json:

```json
[
    {
        "parent": "",
        "name": "root-management-group-02",
        "level": 0
    },
    {
        "parent": "",
        "name": "root-management-group-01",
        "level": 0
    },
    {
        "parent": "root-management-group-01",
        "name": "second-child-root-management-group-01",
        "level": 1
    },
    {
        "parent": "second-child-root-management-group-01",
        "name": "second-grandchild-root-management-group-01",
        "level": 2
    },
    {
        "parent": "second-child-root-management-group-01",
        "name": "first-grandchild-root-management-group-01",
        "level": 2
    },
    {
        "parent": "first-grandchild-root-management-group-01",
        "name": "first-grandgrandchild-root-management-group-01",
        "level": 3
    },
    {
        "parent": "root-management-group-01",
        "name": "third-child-root-management-group-01",
        "level": 1
    },
    {
        "parent": "root-management-group-01",
        "name": "first-child-root-management-group-01",
        "level": 1
    }
]
```

Outputs:



## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_management_group.management_group_four](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) | resource |
| [azurerm_management_group.management_group_one](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) | resource |
| [azurerm_management_group.management_group_three](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) | resource |
| [azurerm_management_group.management_group_two](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) | resource |
| [azurerm_management_group.management_group_ziro](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data"></a> [data](#input\_data) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azurerm_management_group_management_group_one"></a> [azurerm\_management\_group\_management\_group\_one](#output\_azurerm\_management\_group\_management\_group\_one) | n/a |
| <a name="output_json_data_content"></a> [json\_data\_content](#output\_json\_data\_content) | n/a |
