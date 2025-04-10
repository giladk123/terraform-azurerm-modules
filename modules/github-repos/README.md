# GitHub Repositories Terraform Module

This Terraform module creates multiple GitHub repositories with configurable settings.

## Features

- Create multiple GitHub repositories
- Configure repository visibility (public/private)
- Set repository descriptions
- Add topic tags
- Configure GitIgnore templates
- Set license templates

## Usage

The module is designed to be used with a JSON-encoded variable containing repository configurations.

```hcl
locals {
  repos = jsondecode(var.repositories)
}

module "github-repos" {
  source  = "app.terraform.io/hcta-azure-dev/modules/azurerm//modules/github-repos"
  version = "1.0.20"
  repositories = local.repos.repositories
}
```

Example `terraform.tfvars`:
```hcl
repositories = jsonencode({
  "repositories": {
    "repo1": {
      "name": "my-first-repo",
      "description": "First repository created via Terraform",
      "visibility": "private",
      "topics": ["terraform", "infrastructure"],
      "gitignore_template": "Terraform",
      "license_template": "mit"
    },
    "repo2": {
      "name": "my-second-repo",
      "description": "Second repository created via Terraform",
      "visibility": "public",
      "topics": ["automation", "devops"],
      "gitignore_template": "Node",
      "license_template": "apache-2.0"
    }
  }
})
```

Example `variables.tf`:
```hcl
variable "repositories" {
  description = "JSON-encoded string of repository configurations"
  type        = string
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0.0 |
| github | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| github | >= 5.0 |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| repositories | Map of repository configurations | map(object) | yes |

### Repository Configuration Object

```hcl
object({
  name               = string
  description        = string
  visibility         = string
  topics            = optional(list(string))
  gitignore_template = optional(string)
  license_template   = optional(string)
})
```

### Available Options

- `visibility`: "private" or "public"
- `gitignore_template`: "Terraform", "Node", "Python", "Go", "Java", etc.
- `license_template`: "mit", "apache-2.0", "gpl-3.0", "mpl-2.0", etc.

## Outputs

| Name | Description |
|------|-------------|
| repository_urls | Map of repository names to their URLs |

## Example with JSON Configuration

```hcl
locals {
  repos = jsondecode(file("${path.module}/repos.json"))
}

module "github_repositories" {
  source       = "path/to/modules/github-repos"
  repositories = local.repos.repositories
}
```

Example `repos.json`:
```json
{
  "repositories": {
    "repo1": {
      "name": "my-first-repo",
      "description": "First repository created via Terraform",
      "visibility": "private",
      "topics": ["terraform", "infrastructure"],
      "gitignore_template": "Terraform",
      "license_template": "mit"
    }
  }
}
```

## Notes

- Ensure you have set the `GITHUB_TOKEN` environment variable or configured the GitHub provider with appropriate credentials
- Repository names must be unique within your GitHub account
- Some features might require specific GitHub account permissions

## License

MIT License