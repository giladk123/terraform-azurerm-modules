provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
}

# Create provider aliases for each unique subscription
provider "azurerm" {
  alias = "subscription"
  for_each = toset(distinct([for rg in var.resource_groups : rg.value.subscription_id]))

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
  subscription_id           = each.value
} 