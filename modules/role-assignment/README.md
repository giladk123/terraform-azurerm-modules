## Usage

```terraform
module "role-assignment" {
  source = "./module/role-assignment"  # Update this with the actual path to your module

  azure_rbac = [
    {
      key           = "role1"
      scope         = data.azurerm_subscription.current.id  # Use the subscription ID as the scope
      role          = "Contributor"
      principal_id  = data.azuread_group.example.object_id
    },
    {
      key           = "role2"
      scope         = data.azurerm_subscription.sandbox.id  # Use the subscription ID as the scope
      role          = "Contributor"
      principal_id  = data.azuread_group.example.object_id
    }
  ]
}
```

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
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_rbac"></a> [azure\_rbac](#input\_azure\_rbac) | List of objects with parameters to create role assignment | <pre>list(object({<br>    key          = string<br>    scope        = string<br>    principal_id = string<br>    role         = string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_assignments"></a> [role\_assignments](#output\_role\_assignments) | All of the role assignments |
