variable "zones" {
  description = "A list of DNS zone names"
  type        = list(string)
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}