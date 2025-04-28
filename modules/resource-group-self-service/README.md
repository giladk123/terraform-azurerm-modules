# Azure Resource Group Self-Service Module

This Terraform module creates Azure Resource Groups with support for multiple subscriptions. It's designed for self-service scenarios where different resource groups need to be created in different subscriptions.

## Features

- Create multiple resource groups in different Azure subscriptions
- Support for custom tags and locations
- Dynamic provider configuration for each subscription
- Output resource group IDs, locations, and tags

## Usage

```hcl
module "self_service_resource_groups" {
  source = "app.terraform.io/hcta-azure-dev/modules/azurerm//modules/resource-group-self-service"
  version = "1.0.0"

  resource_groups = {
    "rg1" = {
      subscription_id = "00000000-0000-0000-0000-000000000000"
      rg_location    = "westeurope"
      rg_tags        = {
        environment = "dev"
        managed_by  = "terraform"
      }
    },
    "rg2" = {
      subscription_id = "11111111-1111-1111-1111-111111111111"
      rg_location    = "eastus"
      rg_tags        = {
        environment = "prod"
        managed_by  = "terraform"
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
| resource_groups | Map of resource groups to create, with their respective subscription IDs | <pre>map(object({<br>  subscription_id = string<br>  rg_location    = string<br>  rg_tags        = map(string)<br>}))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| resource_group_ids | The IDs of the created resource groups |
| resource_group_locations | The locations of the created resource groups |
| resource_group_tags | The tags of the created resource groups |

## Example Output

```hcl
resource_group_ids = {
  "rg1" = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg1"
  "rg2" = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg2"
}

resource_group_locations = {
  "rg1" = "westeurope"
  "rg2" = "eastus"
}

resource_group_tags = {
  "rg1" = {
    "environment" = "dev"
    "managed_by"  = "terraform"
  }
  "rg2" = {
    "environment" = "prod"
    "managed_by"  = "terraform"
  }
}
```

## Notes

- Each resource group can be created in a different subscription
- The module automatically creates provider aliases for each unique subscription
- Resource groups are created with the specified tags and location
- The module supports Terraform Cloud and can be used in self-service scenarios 