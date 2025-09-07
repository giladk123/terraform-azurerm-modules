# Example: Using the AKS Module with JSON Configuration

# Configure the Azure Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Example 1: Basic AKS Cluster
# Load basic AKS cluster configuration from JSON
locals {
  basic_aks_clusters = jsondecode(file("${path.module}/basic-aks-cluster.json"))
}

module "basic_aks" {
  source = "../../modules/aks"

  aks_clusters = local.basic_aks_clusters
}

# Example 2: Advanced AKS Cluster (commented out - uncomment to deploy)
# locals {
#   advanced_aks_clusters = jsondecode(file("${path.module}/advanced-aks-cluster.json"))
# }

# module "advanced_aks" {
#   source = "../../modules/aks"
#   
#   aks_clusters = local.advanced_aks_clusters
# }

# Example 3: Private AKS Cluster (commented out - uncomment to deploy)
# locals {
#   private_aks_clusters = jsondecode(file("${path.module}/private-aks-cluster.json"))
# }

# module "private_aks" {
#   source = "../../modules/aks"
#   
#   aks_clusters = local.private_aks_clusters
# }

# Example 4: Multiple clusters from a single JSON file
# locals {
#   multi_aks_clusters = jsondecode(file("${path.module}/multi-cluster-example.json"))
# }

# module "multi_aks" {
#   source = "../../modules/aks"
#   
#   aks_clusters = local.multi_aks_clusters
# }
