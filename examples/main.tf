locals {
  app_services = jsondecode(file("${path.module}/app-services.json"))
}

resource "azurerm_resource_group" "rg" {
  name     = "my-resource-group"
  location = "westeurope"
}

module "app_services" {
  source = "../modules/app-service-container"
  
  app_services = local.app_services

  depends_on = [azurerm_resource_group.rg]
} 