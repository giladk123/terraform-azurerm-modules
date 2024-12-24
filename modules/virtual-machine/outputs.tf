output "vm_ids" {
  description = "IDs of the virtual machines."
  value       = { for k, v in azurerm_linux_virtual_machine.vm : k => v.id }
}

output "vm_public_ips" {
  description = "Public IPs of the virtual machines."
  value = {
    for k, v in azurerm_public_ip.pip :
    k => v.ip_address
  }
}

output "vm_names" {
  description = "Names of the virtual machines."
  value       = [for vm in azurerm_linux_virtual_machine.vm : vm.name]
}

output "network_interface_ids" {
  description = "Network Interface IDs of the virtual machines."
  value       = { for k, v in azurerm_network_interface.nic : k => v.id }
}

output "public_ip_dns_names" {
  description = "DNS names of the public IPs."
  value       = { for k, v in azurerm_public_ip.pip : k => v.dns_settings[0].domain_name_label }
}

output "nsg_associations" {
  description = "Network Security Group Associations of the virtual machines."
  value       = { for k, v in azurerm_network_interface_security_group_association.nsg_association : k => v.id }
}