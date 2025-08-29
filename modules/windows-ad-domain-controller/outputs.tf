output "vm_id" {
  value       = azurerm_windows_virtual_machine.dc.id
  description = "ID of the domain controller VM"
}

output "private_ip" {
  value       = azurerm_network_interface.nic.ip_configuration[0].private_ip_address
  description = "Private IP of the domain controller"
}

output "domain_fqdn" {
  value       = var.domain.domain_fqdn
  description = "AD domain FQDN"
}

output "ldap_bind_dn" {
  value       = (var.ldap_user != null && try(var.ldap_user.create, false)) ? "CN=${var.ldap_user.username},${var.ldap_user.ou_dn},DC=${join(",DC=", split(".", var.domain.domain_fqdn))}" : null
  description = "Distinguished Name for LDAP bind user (if created)"
}


