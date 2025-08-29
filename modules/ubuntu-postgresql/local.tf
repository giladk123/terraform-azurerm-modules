locals {
  name_prefix = "${var.name_convention.region}-${var.name_convention.dbank_idbank_first_letter}${var.name_convention.env}-${var.name_convention.cmdb_infra}-${var.name_convention.cmdb_project}"

  cloud_init = base64encode(templatefile("${path.module}/scripts/bootstrap-postgres.sh", {
    pg_version        = var.postgres.version
    db_name           = var.postgres.db_name
    db_owner          = var.postgres.db_owner
    db_owner_password = var.postgres.db_owner_password
    listen_addresses  = var.postgres.listen_addresses
    port              = var.postgres.port
    ldap_domain_fqdn  = var.ldap.domain_fqdn
    ldap_bind_dn      = var.ldap.bind_dn
    ldap_bind_password= var.ldap.bind_password
    ldap_search_base  = var.ldap.search_base
    ldap_server_host  = var.ldap.server_host
  }))
}


