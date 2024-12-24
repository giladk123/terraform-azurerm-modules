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

{
  "vms": {
    "bastion": {
      "resource_group": "we-iydy-sndb-abcd-xxxxxx-rg",
      "location": "westeurope",
      "size": "Standard_DS1_v2",
      "ssh_public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACA.....",
      "admin_username": "azureuser",
      "image_offer": "ubuntu-24_04-lts",
      "image_publisher": "Canonical",
      "image_sku": "server",
      "image_version": "latest",
      "network_security_group_name": "nsg-vm1",
      "security_rules": [
        {
          "name": "SSH",
          "priority": 100,
          "direction": "Inbound",
          "access": "Allow",
          "protocol": "Tcp",
          "source_port_range": "*",
          "destination_port_range": "22",
          "source_address_prefix": "*",
          "destination_address_prefix": "*"
        }
      ],
      "private_ip_address": "10.62.252.4",
      "create_public_ip": true,
      "public_ip_allocation_method": "Dynamic",
      "public_ip_dns_name": "vm1-dns",
      "tags": {
        "Environment": "dev"
      }
    }
  },
  "name_convention": {
    "region": "we",
    "dbank_idbank_first_letter": "i",
    "env": "ydy",
    "cmdb_infra": "sndb",
    "cmdb_project": "abcd"
  }
}

```