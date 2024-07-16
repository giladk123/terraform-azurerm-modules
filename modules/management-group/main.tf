locals {
  json_data = jsondecode(file(var.data))
}

resource "azurerm_management_group" "management_group_ziro" {
  for_each = { for mg in local.json_data : mg.name => mg if mg.level == 0 }

  display_name = each.value.name
  name         = each.value.name
}

resource "azurerm_management_group" "management_group_one" {
  for_each = { for mg in local.json_data : mg.name => mg if mg.level == 1 }

  display_name               = each.value.name
  name                       = each.value.name
  parent_management_group_id = azurerm_management_group.management_group_ziro[each.value.parent].id
  depends_on                 = [azurerm_management_group.management_group_ziro]
}

resource "azurerm_management_group" "management_group_two" {
  for_each = { for mg in local.json_data : mg.name => mg if mg.level == 2 }

  display_name               = each.value.name
  name                       = each.value.name
  parent_management_group_id = azurerm_management_group.management_group_one[each.value.parent].id
  depends_on                 = [azurerm_management_group.management_group_one]
}

resource "azurerm_management_group" "management_group_three" {
  for_each = { for mg in local.json_data : mg.name => mg if mg.level == 3 }

  display_name               = each.value.name
  name                       = each.value.name
  parent_management_group_id = azurerm_management_group.management_group_two[each.value.parent].id
  depends_on                 = [azurerm_management_group.management_group_two]
}

resource "azurerm_management_group" "management_group_four" {
  for_each = { for mg in local.json_data : mg.name => mg if mg.level == 4 }

  display_name               = each.value.name
  name                       = each.value.name
  parent_management_group_id = azurerm_management_group.management_group_three[each.value.parent].id

  depends_on = [azurerm_management_group.management_group_three]
}