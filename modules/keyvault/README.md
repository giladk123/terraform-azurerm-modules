## Usage

```terraform

locals {
    keyvault = jsondecode(file("./ccoe/keyvault.json"))
}

module "keyvault" {
  source = "./module/keyvault"

  keyvaults = local.keyvault.keyvaults
  
}
```

JSON

```json

{
    "keyvaults": {
        "<keyvault name 1>": {
            "location": "West Europe",
            "resource_group_name": "<resource group>",
            "tenant_id": "<tenannt ID>",
            "soft_delete_retention_days": <number>,
            "purge_protection_enabled": true,
            "sku_name": "<sku>",
            "public_network_access_enabled": false
        },
        "<keyvault name 2>": {
            "location": "West Europe",
            "resource_group_name": "<resource group>",
            "tenant_id": "<tenant ID>",
            "soft_delete_retention_days": <number>,
            "purge_protection_enabled": true,
            "sku_name": "<sku>",
            "public_network_access_enabled": false
        }
    }
}
```


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.11, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.11, < 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_keyvaults"></a> [keyvaults](#input\_keyvaults) | The keyvaults to create | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_keyvault"></a> [keyvault](#output\_keyvault) | values of the keyvault |
