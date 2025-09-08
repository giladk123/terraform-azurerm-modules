terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

# Namespace for ArgoCD
resource "kubernetes_namespace" "argocd" {
  for_each = var.argocd_deployments

  metadata {
    name = each.value.namespace
    labels = merge(
      {
        "app.kubernetes.io/name"    = "argocd"
        "app.kubernetes.io/part-of" = "argocd"
      },
      each.value.namespace_labels
    )
    annotations = each.value.namespace_annotations
  }
}

# ArgoCD Helm Release
resource "helm_release" "argocd" {
  for_each = var.argocd_deployments

  name       = each.value.release_name
  repository = each.value.chart_repository
  chart      = each.value.chart_name
  version    = each.value.chart_version
  namespace  = kubernetes_namespace.argocd[each.key].metadata[0].name

  # Wait for deployment to be ready
  wait             = each.value.wait_for_deployment
  timeout          = each.value.deployment_timeout
  create_namespace = false # We create the namespace explicitly above
  atomic           = each.value.atomic
  cleanup_on_fail  = each.value.cleanup_on_fail
  force_update     = each.value.force_update
  recreate_pods    = each.value.recreate_pods

  # Values configuration
  values = [
    templatefile("${path.module}/templates/values.yaml.tpl", {
      server_service_type         = each.value.server.service_type
      server_ingress_enabled      = each.value.server.ingress.enabled
      server_ingress_class        = each.value.server.ingress.ingress_class
      server_ingress_hostname     = each.value.server.ingress.hostname
      server_ingress_tls_enabled  = each.value.server.ingress.tls.enabled
      server_ingress_cert_manager = each.value.server.ingress.tls.cert_manager
      server_ingress_annotations  = jsonencode(each.value.server.ingress.annotations)

      # High Availability settings
      controller_replicas  = each.value.high_availability.enabled ? each.value.high_availability.controller_replicas : 1
      server_replicas      = each.value.high_availability.enabled ? each.value.high_availability.server_replicas : 1
      repo_server_replicas = each.value.high_availability.enabled ? each.value.high_availability.repo_server_replicas : 1

      # Resource settings
      controller_resources  = jsonencode(each.value.resources.controller)
      server_resources      = jsonencode(each.value.resources.server)
      repo_server_resources = jsonencode(each.value.resources.repo_server)

      # Security settings
      enable_rbac           = each.value.security.rbac_enabled
      admin_password_bcrypt = each.value.security.admin_password_bcrypt

      # Additional configurations
      configs = jsonencode(each.value.configs)

      # Node selector and tolerations
      node_selector = jsonencode(each.value.node_selector)
      tolerations   = jsonencode(each.value.tolerations)
      affinity      = jsonencode(each.value.affinity)
    })
  ]

  # Additional Helm values using set blocks
  dynamic "set" {
    for_each = each.value.helm_values
    content {
      name  = set.key
      value = set.value
      type  = "string"
    }
  }

  # Sensitive values using set_sensitive blocks
  dynamic "set_sensitive" {
    for_each = each.value.helm_sensitive_values
    content {
      name  = set_sensitive.key
      value = set_sensitive.value
      type  = "string"
    }
  }

  depends_on = [kubernetes_namespace.argocd]
}

# Create initial ArgoCD admin secret if specified
resource "kubernetes_secret" "argocd_initial_admin_secret" {
  for_each = {
    for k, v in var.argocd_deployments : k => v
    if v.security.create_initial_admin_secret
  }

  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd[each.key].metadata[0].name
    labels = {
      "app.kubernetes.io/name"    = "argocd-initial-admin-secret"
      "app.kubernetes.io/part-of" = "argocd"
    }
  }

  data = {
    password = each.value.security.initial_admin_password
  }

  type = "Opaque"

  depends_on = [kubernetes_namespace.argocd]
}

# ArgoCD CLI Service Account (for CI/CD integration)
resource "kubernetes_service_account" "argocd_cli" {
  for_each = {
    for k, v in var.argocd_deployments : k => v
    if v.create_cli_service_account
  }

  metadata {
    name      = "argocd-cli"
    namespace = kubernetes_namespace.argocd[each.key].metadata[0].name
    labels = {
      "app.kubernetes.io/name"    = "argocd-cli"
      "app.kubernetes.io/part-of" = "argocd"
    }
  }

  depends_on = [kubernetes_namespace.argocd]
}

# ClusterRole for ArgoCD CLI Service Account
resource "kubernetes_cluster_role_binding" "argocd_cli" {
  for_each = {
    for k, v in var.argocd_deployments : k => v
    if v.create_cli_service_account && v.cli_service_account_cluster_admin
  }

  metadata {
    name = "argocd-cli-${each.key}"
    labels = {
      "app.kubernetes.io/name"    = "argocd-cli"
      "app.kubernetes.io/part-of" = "argocd"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.argocd_cli[each.key].metadata[0].name
    namespace = kubernetes_namespace.argocd[each.key].metadata[0].name
  }

  depends_on = [kubernetes_service_account.argocd_cli]
}

# ArgoCD Projects (if specified)
resource "kubernetes_manifest" "argocd_projects" {
  for_each = merge([
    for deployment_key, deployment in var.argocd_deployments : {
      for project_key, project in deployment.projects : "${deployment_key}-${project_key}" => merge(project, {
        deployment_key = deployment_key
        namespace      = deployment.namespace
      })
    }
  ]...)

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = each.value.name
      namespace = each.value.namespace
      labels = merge(
        {
          "app.kubernetes.io/name"    = "argocd-project"
          "app.kubernetes.io/part-of" = "argocd"
        },
        each.value.labels
      )
      annotations = each.value.annotations
    }
    spec = {
      description = each.value.description

      sourceRepos = each.value.source_repos

      destinations = [
        for dest in each.value.destinations : {
          server    = dest.server
          namespace = dest.namespace
        }
      ]

      clusterResourceWhitelist   = each.value.cluster_resource_whitelist
      namespaceResourceWhitelist = each.value.namespace_resource_whitelist

      roles = [
        for role in each.value.roles : {
          name        = role.name
          description = role.description
          policies    = role.policies
          groups      = role.groups
        }
      ]
    }
  }

  depends_on = [helm_release.argocd]
}

# ArgoCD Applications (if specified)
resource "kubernetes_manifest" "argocd_applications" {
  for_each = merge([
    for deployment_key, deployment in var.argocd_deployments : {
      for app_key, app in deployment.applications : "${deployment_key}-${app_key}" => merge(app, {
        deployment_key = deployment_key
        namespace      = deployment.namespace
      })
    }
  ]...)

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = each.value.name
      namespace = each.value.namespace
      labels = merge(
        {
          "app.kubernetes.io/name"    = "argocd-application"
          "app.kubernetes.io/part-of" = "argocd"
        },
        each.value.labels
      )
      annotations = each.value.annotations
      finalizers  = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      project = each.value.project

      source = merge(
        {
          repoURL        = each.value.source.repo_url
          path           = each.value.source.path
          targetRevision = each.value.source.target_revision
        },
        each.value.source.helm != null ? {
          helm = {
            valueFiles = each.value.source.helm.value_files
            values     = each.value.source.helm.values
          }
        } : {},
        each.value.source.kustomize != null ? {
          kustomize = {
            namePrefix = each.value.source.kustomize.name_prefix
            nameSuffix = each.value.source.kustomize.name_suffix
            images     = each.value.source.kustomize.images
          }
        } : {}
      )

      destination = {
        server    = each.value.destination.server
        namespace = each.value.destination.namespace
      }

      syncPolicy = {
        automated = each.value.sync_policy.automated != null ? {
          prune    = each.value.sync_policy.automated.prune
          selfHeal = each.value.sync_policy.automated.self_heal
        } : null

        syncOptions = each.value.sync_policy.sync_options
        retry = each.value.sync_policy.retry != null ? {
          limit = each.value.sync_policy.retry.limit
          backoff = {
            duration    = each.value.sync_policy.retry.backoff.duration
            factor      = each.value.sync_policy.retry.backoff.factor
            maxDuration = each.value.sync_policy.retry.backoff.max_duration
          }
        } : null
      }
    }
  }

  depends_on = [helm_release.argocd, kubernetes_manifest.argocd_projects]
}
