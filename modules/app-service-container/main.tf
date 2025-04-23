resource "azurerm_service_plan" "app_service_plan" {
  for_each            = var.app_services
  name                = "${each.value.name}-plan"
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  os_type             = "Linux"
  sku_name            = each.value.sku_name
}

resource "azurerm_linux_web_app" "app_service" {
  for_each            = var.app_services
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  service_plan_id     = azurerm_service_plan.app_service_plan[each.key].id

  site_config {
    application_stack {
      docker_image_name = try(each.value.app_settings.DOCKER_CUSTOM_IMAGE_NAME, "${each.value.docker_image}:${each.value.docker_image_tag}")
    }

    always_on                               = try(each.value.always_on, true)
    container_registry_use_managed_identity = try(each.value.container_registry_use_managed_identity, true)
  }

  app_settings = merge(
    try(each.value.app_settings, {}),
    {
      "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false",
      "DOCKER_REGISTRY_SERVER_URL" = try(each.value.registry.url, "https://index.docker.io/v1/")
    },
    # Add credentials only if username and password are provided
    try(each.value.registry.username, null) != null && try(each.value.registry.password, null) != null ? {
      "DOCKER_REGISTRY_SERVER_USERNAME" = each.value.registry.username
      "DOCKER_REGISTRY_SERVER_PASSWORD" = each.value.registry.password
    } : {}
  )

  identity {
    type = "SystemAssigned"
  }

  tags = try(each.value.tags, {})
}
