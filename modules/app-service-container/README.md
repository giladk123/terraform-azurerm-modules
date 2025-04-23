# Azure App Service Container Module

This Terraform module deploys one or more Azure App Services configured to run containerized applications. The module supports multiple app services using `for_each` and configuration via JSON.

## Features

- Deploy multiple App Services using a single module
- Support for containerized applications
- Configurable App Service Plan
- Managed Identity support for container registry access
- Customizable app settings
- Flexible configuration through JSON

## Requirements

- Terraform >= 0.13.x
- Azure Provider >= 3.0.0
- Azure subscription
- Azure CLI or other authentication mechanism

## Usage

1. Create a JSON configuration file (e.g., `app-services.json`):

```json
{
  "app1": {
    "name": "my-python-app",
    "resource_group_name": "my-rg",
    "location": "westeurope",
    "sku_name": "P1v2",
    "docker_image": "python",
    "docker_image_tag": "3.9",
    "always_on": true,
    "app_settings": {
      "PYTHON_ENV": "production",
      "WEBSITES_PORT": "8000"
    },
    "tags": {
      "environment": "production"
    }
  }
}
```

2. Use the module in your Terraform configuration:

```hcl
locals {
  app_services = jsondecode(file("${path.module}/app-services.json"))
}

module "app_services" {
  source = "path/to/module"
  
  app_services = local.app_services
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| app_services | Map of app services to create | map(object) | Yes |

### App Service Object Structure

```hcl
object({
  name                = string
  resource_group_name = string
  location           = string
  sku_name           = string
  docker_image       = string
  docker_image_tag   = string
  docker_registry_server_url = optional(string)
  always_on          = optional(bool)
  container_registry_use_managed_identity = optional(bool)
  app_settings       = optional(map(string))
  tags               = optional(map(string))
})
```

## Outputs

| Name | Description |
|------|-------------|
| app_service_names | Map of created app service names |
| app_service_urls | Map of app service URLs |
| app_service_identities | Map of app service managed identity principal IDs |

## Example

Complete example with multiple app services:

```hcl
locals {
  app_services = {
    "python_app_1" = {
      name                = "python-web-app-1"
      resource_group_name = "my-resource-group"
      location            = "westeurope"
      sku_name           = "P1v2"
      docker_image       = "python"
      docker_image_tag   = "3.9"
      always_on          = true
      app_settings       = {
        "PYTHON_ENV"     = "production"
        "WEBSITES_PORT"  = "8000"
      }
      tags = {
        environment = "production"
        app        = "python-web"
      }
    }
  }
}

module "app_services" {
  source = "path/to/module"
  
  app_services = local.app_services
}
```

## Notes

- The module automatically creates an App Service Plan for each App Service
- System-assigned managed identity is enabled by default
- Default container registry is Docker Hub (configurable via `docker_registry_server_url`)
- App Service Plan name is automatically generated as `${app_service_name}-plan`

## Contributing

Feel free to submit issues and enhancement requests! 