locals {
  name_prefix = "${var.name_convention.region}-${var.name_convention.dbank_idbank_first_letter}${var.name_convention.env}-${var.name_convention.cmdb_infra}-${var.name_convention.cmdb_project}"

  dc_custom_data = base64encode(templatefile("${path.module}/scripts/bootstrap-ad.ps1", {
    domain_fqdn        = var.domain.domain_fqdn
    netbios_name       = var.domain.netbios_name
    safe_mode_password = var.domain.safe_mode_password
    site_name          = var.domain.site_name
    create_user        = var.ldap_user != null && try(var.ldap_user.create, false)
    user_username      = var.ldap_user != null ? try(var.ldap_user.username, null) : null
    user_password      = var.ldap_user != null ? try(var.ldap_user.password, null) : null
    user_ou_dn         = var.ldap_user != null ? try(var.ldap_user.ou_dn, null) : null
    user_given_name    = var.ldap_user != null ? try(var.ldap_user.given_name, null) : null
    user_surname       = var.ldap_user != null ? try(var.ldap_user.surname, null) : null
  }))
}


