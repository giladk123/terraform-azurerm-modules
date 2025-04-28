# Azure provider configuration
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  resource_provider_registrations = "core"
}

# Create provider aliases for each unique subscription
provider "azurerm" {
  alias = "aliases"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  resource_provider_registrations = "core"
} 