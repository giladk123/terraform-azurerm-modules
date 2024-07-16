## Usage

add locals with service principal and role assignment:

```terraform

locals {
  service-principal = jsondecode(file("./ccoe/service-principal.json"))
  assignments = [
    {
      sp_name = "secret-api-1",
      scope = data.azurerm_subscription.current.id,
      role_definition_name = "Contributor"
    },
    {
      sp_name = "secret-api-2",
      scope = data.azurerm_subscription.current.id,
      role_definition_name = "Reader"
    }
  ]
}

```

add module : 

```terraform

module "service-principal" {
  source = "./module/service-principal"

  service_principals = local.service-principal
  assignments = local.assignments

}

```


Example of the service-principal.json : 

```json

[
    {
      "name": "<service principal name>",
      "owner_username": "<user principal id>",
      "client_secret_name": "<client secret name>",
      "secret_rotation_days": <number>
    },
    {
      "name": "<service principal name>",
      "owner_username": "<user principal id>",
      "client_secret_name": "<client secret name>",
      "secret_rotation_days": <number>
    }
  ]
```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_application.sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_password.app](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_service_principal.sp](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal_password.application](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal_password) | resource |
| [azurerm_role_assignment.assignments](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [time_rotating.year](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azuread_user.owner](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assignments"></a> [assignments](#input\_assignments) | List of role assignments | <pre>list(object({<br>    sp_name              = string<br>    scope                = string<br>    role_definition_name = string<br>  }))</pre> | n/a | yes |
| <a name="input_service_principals"></a> [service\_principals](#input\_service\_principals) | The service principals | <pre>list(object({<br>    name                 = string<br>    owner_username       = string<br>    #app_password_name    = string<br>    client_secret_name   = string<br>    secret_rotation_days = number<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_registration_application_id"></a> [app\_registration\_application\_id](#output\_app\_registration\_application\_id) | The application IDs of the Azure AD applications |
| <a name="output_app_registration_client_secret"></a> [app\_registration\_client\_secret](#output\_app\_registration\_client\_secret) | The client secret for the Azure AD Application. |
| <a name="output_app_registration_object_id"></a> [app\_registration\_object\_id](#output\_app\_registration\_object\_id) | The object IDs of the Azure AD applications. |
| <a name="output_sp_application_id"></a> [sp\_application\_id](#output\_sp\_application\_id) | The application IDs of the Azure AD service principals |
| <a name="output_sp_client_secret"></a> [sp\_client\_secret](#output\_sp\_client\_secret) | The client secret for the Azure AD Service Principal. |
| <a name="output_sp_object_id"></a> [sp\_object\_id](#output\_sp\_object\_id) | The object IDs of the Azure AD service principals. |
