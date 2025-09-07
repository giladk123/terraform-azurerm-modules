terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.81.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  cfg         = jsondecode(file(var.config_json))
  name_prefix = "${local.cfg.name_convention.region}-${local.cfg.name_convention.dbank_idbank_first_letter}${local.cfg.name_convention.env}-${local.cfg.name_convention.cmdb_infra}-${local.cfg.name_convention.cmdb_project}"
  rg_name     = "${local.name_prefix}-main-rg"
}

module "resource_group" {
  source          = "../..//modules/resource-group-self-service"
  subscription_id = var.subscription_id
  resource_groups = {
    main = {
      name_convention = local.cfg.name_convention
      rg_location     = local.cfg.resource_group.location
      rg_tags         = local.cfg.tags
    }
  }
}

module "vnet" {
  source = "../..//modules/vnet-self-service"
  vnet_config = {
    main = {
      name                = local.cfg.vnet.name
      resource_group_name = local.rg_name
      location            = local.cfg.resource_group.location
      address_space       = local.cfg.vnet.address_space
      subnets = {
        ad = {
          name             = "ad"
          address_prefixes = [local.cfg.vnet.subnets.ad.prefix]
        }
        pg = {
          name             = "pg"
          address_prefixes = [local.cfg.vnet.subnets.pg.prefix]
        }
      }
    }
  }
}

module "ad" {
  source          = "../..//modules/windows-ad-domain-controller"
  name_convention = local.cfg.name_convention
  vm = merge(local.cfg.ad.vm, {
    resource_group = local.rg_name
    location       = local.cfg.resource_group.location
    subnet_id      = module.vnet.subnet_ids["main-ad"]
    tags           = local.cfg.tags
  })
  domain    = local.cfg.ad.domain
  ldap_user = local.cfg.ad.ldap_user
  nsg = local.cfg.ad.nsg != null ? merge(local.cfg.ad.nsg, {
    name = "${local.name_prefix}-dc-nsg"
  }) : null
}

module "postgres" {
  source          = "../..//modules/ubuntu-postgresql"
  name_convention = local.cfg.name_convention
  vm = merge(local.cfg.postgres.vm, {
    resource_group = local.rg_name
    location       = local.cfg.resource_group.location
    subnet_id      = module.vnet.subnet_ids["main-pg"]
    tags           = local.cfg.tags
  })
  postgres = local.cfg.postgres.postgres
  ldap = {
    domain_fqdn   = module.ad.domain_fqdn
    bind_dn       = coalesce(module.ad.ldap_bind_dn, local.cfg.postgres.ldap.bind_dn)
    bind_password = local.cfg.postgres.ldap.bind_password
    search_base   = local.cfg.postgres.ldap.search_base
    server_host   = module.ad.private_ip
  }
  nsg = local.cfg.postgres.nsg != null ? merge(local.cfg.postgres.nsg, {
    name = "${local.name_prefix}-pg-nsg"
  }) : null
}


