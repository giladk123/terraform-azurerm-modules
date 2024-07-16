## Usage

```terraform

module "azuread_role_assignment" {
  source = "./module/azuread-role-assignment"

  roles_assignments = [
    {
      role_names = [
        "Global Reader",
        "Attack Payload Author",
        "Application Administrator",
        "Global Administrator",
        "Authentication Administrator",
        "Directory Readers",
        "Directory Writers",
        "License Administrator",
        "User Administrator",
        "Yammer Administrator",
        "Windows 365 Administrator",
        "Service Support Administrator",
        "Extended Directory User Administrator"
      ],
      principal_object_ids = [
        "7b033fe8-52db-43cf-987c-20abac52bf05",
        "524a5584-1475-449c-9813-d26d42903d19",
        "da9c795c-fa3b-41f1-ba6a-c9cf69419c28"
      ]
    }

    # Add more role assignments as needed
  ]
}
```

Outputs

```terraform
output "role_assignments_details_from_module" {
  value       = module.azuread_role_assignment.role_assignments_details
  description = "A map of Azure AD role assignments including role IDs and principal object IDs from the azuread_role_assignment module."
}
```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_directory_role_assignment.role_assignment](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role_assignment) | resource |
| [azuread_directory_roles.available_roles](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/directory_roles) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_roles_assignments"></a> [roles\_assignments](#input\_roles\_assignments) | A list of role assignments | <pre>list(object({<br>    role_names           = list(string)<br>    principal_object_ids = list(string)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_assignments_details"></a> [role\_assignments\_details](#output\_role\_assignments\_details) | A map of Azure AD role assignments including role IDs and principal object IDs. |
