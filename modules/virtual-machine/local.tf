locals {
  name_prefix = "${var.name_convention.region}-${var.name_convention.dbank_idbank_first_letter}${var.name_convention.env}-${var.name_convention.cmdb_infra}-${var.name_convention.cmdb_project}"
}