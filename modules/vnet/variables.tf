variable "vnets" { type = map(any) }

variable "name_convention" {
  description = "Naming convention details."
  type = object({
    region                    = string
    dbank_idbank_first_letter = string
    env                       = string
    cmdb_infra                = string
    cmdb_project              = string
  })
}