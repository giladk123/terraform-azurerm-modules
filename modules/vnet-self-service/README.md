# Azure Virtual Network Terraform Module

This Terraform module creates Azure Virtual Networks with multiple subnets using a JSON configuration file.

## Features

- Create multiple Virtual Networks
- Configure multiple subnets per VNet
- Uses `for_each` for efficient resource management
- JSON-based configuration for easy maintenance
- No hardcoded values

## Usage

1. Create a `vnet-config.json` file in your root module:

```json
{
  "prod_vnet": {
    "name": "prod-vnet",
    "resource_group_name": "prod-rg",
    "location": "westeurope",
    "address_space": ["10.0.0.0/16"],
    "subnets": {
      "subnet1": {
        "name": "web-subnet",
        "address_prefixes": ["10.0.1.0/24"]
      },
      "subnet2": {
        "name": "app-subnet",
        "address_prefixes": ["10.0.2.0/24"]
      }
    }
  }
}
```

2. Use the module in your Terraform configuration:

```hcl
locals {
  vnet_config = jsondecode(file("${path.module}/vnet-config.json"))
}

module "vnet" {
  source      = "path/to/module"
  vnet_config = local.vnet_config
}
```

## Requirements

- Terraform >= 0.13.x
- AzureRM Provider >= 2.0

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| vnet_config | Configuration for VNets and subnets | map(object) | yes |

## Outputs

| Name | Description |
|------|-------------|
| vnet_ids | Map of VNet IDs |
| subnet_ids | Map of Subnet IDs |

## Example Usage with Multiple VNets

```json
{
  "prod_vnet": {
    "name": "prod-vnet",
    "resource_group_name": "prod-rg",
    "location": "westeurope",
    "address_space": ["10.0.0.0/16"],
    "subnets": {
      "subnet1": {
        "name": "web-subnet",
        "address_prefixes": ["10.0.1.0/24"]
      }
    }
  },
  "dev_vnet": {
    "name": "dev-vnet",
    "resource_group_name": "dev-rg",
    "location": "westeurope",
    "address_space": ["172.16.0.0/16"],
    "subnets": {
      "subnet1": {
        "name": "dev-subnet",
        "address_prefixes": ["172.16.1.0/24"]
      }
    }
  }
}
```

## Authors

Your Name / Organization
