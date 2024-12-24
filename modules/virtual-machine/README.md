# Azure Virtual Machine Module

## Overview

The Azure Virtual Machine module simplifies the deployment and management of Linux virtual machines in Microsoft Azure. It leverages Terraform to provision VMs with customizable configurations, including networking, security, and initialization scripts.

## Features

- **Customizable VM Configurations:** Define VM size, image, SSH keys, and more.
- **User Data Scripts:** Execute initialization scripts on VM startup.
- **Networking Integration:** Associate VMs with existing virtual networks and subnets.
- **Security:** Configure network security groups and rules.
- **Tagging:** Apply consistent tags for resource management and cost tracking.

## Requirements

- **Terraform:** `>= 1.0`
- **Azure Provider:** `>= 3.0`

## Providers

| Name    | Version |
|---------|---------|
| azurerm | >= 3.0  |

## Module Usage

### Example

```terraform
locals {
  virtual_machines = jsondecode(file("./ccoe/vms.json"))
}

module "virtual_machine" {
  source          = "app.terraform.io/hcta-azure-dev/modules/azurerm//modules/virtual-machine"
  version         = "1.0.17"
  vms             = local.virtual_machines.vms
  subnet_id       = module.vnet.subnet["bastion-subnet1"].id
  name_convention = local.virtual_machines.name_convention
  user_data       = file("${path.module}/ccoe/init.sh")

  depends_on = [module.vnet]
}
```