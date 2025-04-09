output "repository_urls" {
  description = "URLs of all created repositories"
  value       = { for k, v in github_repository.repo : k => v.html_url }
}