resource "azurerm_public_ip" "pip" {
  for_each = {
    for k, v in var.vms : k => v
    if lookup(v, "create_public_ip", false)
  }

  name                = "${each.key}-pip"
  location            = each.value.location
  resource_group_name = each.value.resource_group
  allocation_method   = each.value.public_ip_allocation_method

  lifecycle {
    create_before_destroy = true
  }

  tags = each.value.tags
}

# Create Network Interfaces for each VM
resource "azurerm_network_interface" "nic" {
  for_each = var.vms

  name                = "${each.key}-nic"
  location            = each.value.location
  resource_group_name = each.value.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = each.value.private_ip_address != null ? "Static" : "Dynamic"
    private_ip_address            = each.value.private_ip_address
    public_ip_address_id          = contains(keys(azurerm_public_ip.pip), each.key) ? azurerm_public_ip.pip[each.key].id : null
  }

  tags = each.value.tags
}

# Create Network Security Groups (NSGs) for VMs that specify an NSG
resource "azurerm_network_security_group" "nsg" {
  for_each = {
    for vm_name, vm in var.vms :
    vm_name => vm
    if vm.network_security_group_name != null
  }

  name                = each.value.network_security_group_name
  location            = each.value.location
  resource_group_name = each.value.resource_group

  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  tags = each.value.tags  # Optional: Include tags if needed
}

# Associate NSGs with their corresponding Network Interfaces
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  for_each = {
    for vm_name, vm in var.vms :
    vm_name => vm
    if vm.network_security_group_name != null
  }

  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

# Create Linux Virtual Machines
resource "azurerm_linux_virtual_machine" "vm" {
  for_each = var.vms

  name                = "${local.name_prefix}-${each.key}-vm"
  resource_group_name = each.value.resource_group
  location            = each.value.location
  size                = each.value.size

  admin_username = each.value.admin_username

  admin_ssh_key {
    username   = each.value.admin_username
    public_key = each.value.ssh_public_key
  }

  source_image_reference {
    publisher = each.value.image_publisher
    offer     = each.value.image_offer
    sku       = each.value.image_sku
    version   = each.value.image_version
  }

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  tags = each.value.tags
}