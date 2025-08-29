resource "azurerm_public_ip" "pip" {
  count               = var.vm.create_public_ip ? 1 : 0
  name                = "${local.name_prefix}-pg-pip"
  location            = var.vm.location
  resource_group_name = var.vm.resource_group
  allocation_method   = var.vm.public_ip_allocation_method
  tags                = var.vm.tags
}

resource "azurerm_network_interface" "nic" {
  name                = "${local.name_prefix}-pg-nic"
  location            = var.vm.location
  resource_group_name = var.vm.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vm.subnet_id
    private_ip_address_allocation = var.vm.private_ip_address != null ? "Static" : "Dynamic"
    private_ip_address            = var.vm.private_ip_address
    public_ip_address_id          = length(azurerm_public_ip.pip) > 0 ? azurerm_public_ip.pip[0].id : null
  }

  tags = var.vm.tags
}

resource "azurerm_network_security_group" "nsg" {
  count               = var.nsg != null && try(var.nsg.name, null) != null ? 1 : 0
  name                = var.nsg.name
  location            = var.vm.location
  resource_group_name = var.vm.resource_group

  dynamic "security_rule" {
    for_each = var.nsg != null ? var.nsg.security_rules : []
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = try(security_rule.value.source_port_range, null)
      destination_port_range     = try(security_rule.value.destination_port_range, null)
      source_address_prefix      = try(security_rule.value.source_address_prefix, null)
      destination_address_prefix = try(security_rule.value.destination_address_prefix, null)
    }
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  count                     = length(azurerm_network_security_group.nsg) > 0 ? 1 : 0
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg[0].id
}

resource "azurerm_linux_virtual_machine" "pg" {
  name                = "${local.name_prefix}-pg-vm"
  location            = var.vm.location
  resource_group_name = var.vm.resource_group
  size                = var.vm.size
  admin_username      = var.vm.admin_username

  admin_ssh_key {
    username   = var.vm.admin_username
    public_key = var.vm.ssh_public_key
  }

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-noble"
    sku       = "24_04-lts"
    version   = "latest"
  }

  custom_data = local.cloud_init

  tags = var.vm.tags
}


