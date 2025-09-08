output "argocd_deployments" {
  description = "Map of ArgoCD deployment information"
  value = {
    for key, deployment in var.argocd_deployments : key => {
      namespace     = kubernetes_namespace.argocd[key].metadata[0].name
      release_name  = helm_release.argocd[key].name
      chart_version = helm_release.argocd[key].version
      status        = helm_release.argocd[key].status
    }
  }
}

output "argocd_namespaces" {
  description = "Map of ArgoCD namespace names"
  value = {
    for key, namespace in kubernetes_namespace.argocd : key => namespace.metadata[0].name
  }
}

output "argocd_helm_releases" {
  description = "Map of ArgoCD Helm release information"
  value = {
    for key, release in helm_release.argocd : key => {
      name      = release.name
      version   = release.version
      status    = release.status
      namespace = release.namespace
    }
  }
}

output "argocd_server_urls" {
  description = "Map of ArgoCD server URLs based on ingress configuration"
  value = {
    for key, deployment in var.argocd_deployments : key => {
      internal_url = "http://argocd-server.${kubernetes_namespace.argocd[key].metadata[0].name}.svc.cluster.local"
      external_url = deployment.server.ingress.enabled ? (
        deployment.server.ingress.tls.enabled ?
        "https://${deployment.server.ingress.hostname}" :
        "http://${deployment.server.ingress.hostname}"
      ) : null
    }
  }
}

output "argocd_service_accounts" {
  description = "Map of ArgoCD CLI service accounts"
  value = {
    for key, sa in kubernetes_service_account.argocd_cli : key => {
      name      = sa.metadata[0].name
      namespace = sa.metadata[0].namespace
    }
  }
}

output "argocd_projects" {
  description = "Map of created ArgoCD projects"
  value = {
    for key, project in kubernetes_manifest.argocd_projects : key => {
      name      = project.manifest.metadata.name
      namespace = project.manifest.metadata.namespace
    }
  }
}

output "argocd_applications" {
  description = "Map of created ArgoCD applications"
  value = {
    for key, app in kubernetes_manifest.argocd_applications : key => {
      name      = app.manifest.metadata.name
      namespace = app.manifest.metadata.namespace
      project   = app.manifest.spec.project
    }
  }
}

output "argocd_admin_secrets" {
  description = "Map of ArgoCD admin secret names (for initial password setup)"
  value = {
    for key, secret in kubernetes_secret.argocd_initial_admin_secret : key => {
      name      = secret.metadata[0].name
      namespace = secret.metadata[0].namespace
    }
  }
  sensitive = true
}

# Connection information for CLI access
output "argocd_cli_connection_info" {
  description = "ArgoCD CLI connection information"
  value = {
    for key, deployment in var.argocd_deployments : key => {
      server_url = deployment.server.ingress.enabled ? (
        deployment.server.ingress.tls.enabled ?
        "https://${deployment.server.ingress.hostname}" :
        "http://${deployment.server.ingress.hostname}"
      ) : "argocd-server.${kubernetes_namespace.argocd[key].metadata[0].name}.svc.cluster.local"

      namespace = kubernetes_namespace.argocd[key].metadata[0].name

      # Instructions for port-forwarding if no ingress
      port_forward_command = !deployment.server.ingress.enabled ? "kubectl port-forward svc/argocd-server -n ${kubernetes_namespace.argocd[key].metadata[0].name} 8080:443" : null

      # Login command
      login_command = deployment.server.ingress.enabled ? "argocd login ${deployment.server.ingress.hostname}" : "argocd login localhost:8080"
    }
  }
}

# Resource information
output "argocd_resource_summary" {
  description = "Summary of created ArgoCD resources"
  value = {
    for key, deployment in var.argocd_deployments : key => {
      namespace_created   = kubernetes_namespace.argocd[key].metadata[0].name
      helm_release_status = helm_release.argocd[key].status
      projects_count      = length([for proj_key, proj in deployment.projects : proj_key])
      applications_count  = length([for app_key, app in deployment.applications : app_key])
      cli_service_account = deployment.create_cli_service_account ? kubernetes_service_account.argocd_cli[key].metadata[0].name : null
      high_availability   = deployment.high_availability.enabled
      ingress_enabled     = deployment.server.ingress.enabled
      ingress_hostname    = deployment.server.ingress.enabled ? deployment.server.ingress.hostname : null
    }
  }
}
