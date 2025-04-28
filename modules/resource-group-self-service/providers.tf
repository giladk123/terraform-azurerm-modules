provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
}

# Create provider aliases for each unique subscription
locals {
  unique_subscriptions = distinct([for rg in var.resource_groups : rg.value.subscription_id])
}

# Create provider aliases for each unique subscription
provider "azurerm" {
  alias = "subscription_1"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
  subscription_id = local.unique_subscriptions[0]
}

provider "azurerm" {
  alias = "subscription_2"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
  subscription_id = local.unique_subscriptions[1]
}

provider "azurerm" {
  alias = "subscription_3"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
  subscription_id = local.unique_subscriptions[2]
} 