# Azure Resource Group Self-Service Module

This Terraform module creates Azure Resource Groups with a specified subscription ID. It's designed for self-service scenarios where resource groups need to be created in a specific subscription.

## Features

- Create multiple resource groups in a specified Azure subscription
- Support for custom tags and locations
- Dynamic naming convention support
- Output resource group IDs, locations, and tags

## Usage

### Root Module Example

```hcl
# main.tf
module "self_service_resource_groups" {
  source  = "app.terraform.io/hcta-azure-dev/modules/azurerm//modules/resource-group-self-service"
  version = "1.0.41"

  subscription_id = var.subscription_id
  resource_groups = var.resource_groups
}

# variables.tf
variable "subscription_id" {
  description = "The subscription ID to use for the Azure provider"
  type        = string
}

variable "resource_groups" {
  description = "Map of resource groups to create"
  type = map(object({
    name_convention = object({
      region                    = string
      dbank_idbank_first_letter = string
      env                      = string
      cmdb_infra               = string
      cmdb_project             = string
    })
    rg_location = string
    rg_tags     = map(string)
  }))
}

# terraform.tfvars
subscription_id = "00000000-0000-0000-0000-000000000000"
resource_groups = {
  "rg1" = {
    name_convention = {
      region                    = "we"
      dbank_idbank_first_letter = "d"
      env                      = "dev"
      cmdb_infra               = "infra"
      cmdb_project             = "project"
    }
    rg_location = "westeurope"
    rg_tags     = {
      environment = "dev"
      managed_by  = "terraform"
    }
  }
}
```

### JSON Input Example

```json
{
  "subscription_id": "00000000-0000-0000-0000-000000000000",
  "resource_groups": {
    "rg1": {
      "name_convention": {
        "region": "we",
        "dbank_idbank_first_letter": "d",
        "env": "dev",
        "cmdb_infra": "infra",
        "cmdb_project": "project"
      },
      "rg_location": "westeurope",
      "rg_tags": {
        "environment": "dev",
        "managed_by": "terraform"
      }
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| azurerm | > 3.11.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| subscription_id | The subscription ID to use for the Azure provider | string | n/a | yes |
| resource_groups | Map of resource groups to create | <pre>map(object({<br>  name_convention = object({<br>    region                    = string<br>    dbank_idbank_first_letter = string<br>    env                      = string<br>    cmdb_infra               = string<br>    cmdb_project             = string<br>  })<br>  rg_location = string<br>  rg_tags     = map(string)<br>}))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| resource_group_ids | The IDs of the created resource groups |
| resource_group_locations | The locations of the created resource groups |
| resource_group_tags | The tags of the created resource groups |

## Example Output

```hcl
resource_group_ids = {
  "rg1" = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/we-d-dev-infra-project-rg1-rg"
}

resource_group_locations = {
  "rg1" = "westeurope"
}

resource_group_tags = {
  "rg1" = {
    "environment" = "dev"
    "managed_by"  = "terraform"
  }
}
```

## Notes

- Resource groups are created in the specified subscription
- Resource group names follow the naming convention: `{region}-{dbank_idbank_first_letter}-{env}-{cmdb_infra}-{cmdb_project}-{key}-rg`
- Resource groups are created with the specified tags and location
- The module supports Terraform Cloud and can be used in self-service scenarios 