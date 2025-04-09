variable "repositories" {
  description = "Map of repository configurations"
  type = map(object({
    name               = string
    description        = string
    visibility         = string
    auto_init         = optional(bool, true)
    topics            = optional(list(string), [])
    gitignore_template = optional(string)
    license_template   = optional(string)
  }))
}