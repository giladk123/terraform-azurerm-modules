resource "github_repository" "repo" {
  for_each = var.repositories

  name        = each.value.name
  description = each.value.description
  visibility  = each.value.visibility
  auto_init   = each.value.auto_init
  topics      = each.value.topics

  # Add gitignore and license template
  gitignore_template = try(each.value.gitignore_template, null)
  license_template   = try(each.value.license_template, null)
}