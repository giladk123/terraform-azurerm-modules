## Usage

```terraform

locals {
  access_policy       = jsondecode(file("./ccoe/access-policy.json"))
}

module "keyvault-access-policy" {
  source  = "./module/keyvault-access-policy" 

  access_policies = {
    policy1 = {
      key_vault_id = module.keyvault.keyvault["we-ydev-azus-opdx-01-kv"].id
      tenant_id = "233c7c56-1c47-4b81-a976-39ea1da0802a"
      object_id = "5ac7d1b9-f75b-4f2c-af6a-a0e920e6745c"
      key_permissions = local.access_policy.policy1.key_permissions
      secret_permissions = local.access_policy.policy1.secret_permissions
      certificate_permissions = local.access_policy.policy1.certificate_permissions
    },
    policy2 = {
      key_vault_id = module.keyvault.keyvault["we-ydev-azus-opdx-02-kv"].id
      tenant_id = "233c7c56-1c47-4b81-a976-39ea1da0802a"
      object_id = "5ac7d1b9-f75b-4f2c-af6a-a0e920e6745c"
      key_permissions = local.access_policy.policy2.key_permissions
      secret_permissions = local.access_policy.policy2.secret_permissions
      certificate_permissions = local.access_policy.policy2.certificate_permissions
    }
  }
}
```

JSON Example

```json
{
    "policy1": {
      "key_permissions": ["Get", "List", "Delete", "Create", "Import", "Backup", "Restore", "Recover"],
      "secret_permissions": ["Get", "List", "Delete", "Backup", "Restore", "Recover"],
      "certificate_permissions": ["Get", "List", "Delete", "Create", "Import", "Backup", "Restore", "Recover"]
    },
    "policy2": {
      "key_permissions": ["Get", "List"],
      "secret_permissions": ["Get", "List"],
      "certificate_permissions": ["Get", "List"]
    }
  }
```

Outputs : 
```terraform
output "access_policies" {
  description = "Access policies applied to the key vault"
  value       = module.keyvault-access-policy.access_policies
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
| [azurerm_key_vault_access_policy.access_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | Access policies to apply to the key vault | <pre>map(object({<br>    key_vault_id = string<br>    tenant_id = string<br>    #object_id = string<br>    object_id = optional(string)<br>    application_id = optional(string)<br>    key_permissions = list(string)<br>    secret_permissions = list(string)<br>    certificate_permissions = list(string)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_policies"></a> [access\_policies](#output\_access\_policies) | value of the access policies applied to the key vault |
