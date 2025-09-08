variable "argocd_deployments" {
  description = "Map of ArgoCD deployment configurations"
  type = map(object({
    # Basic deployment settings
    namespace        = string
    release_name     = string
    chart_repository = optional(string, "https://argoproj.github.io/argo-helm")
    chart_name       = optional(string, "argo-cd")
    chart_version    = optional(string, "5.51.6")

    # Deployment settings
    wait_for_deployment = optional(bool, true)
    deployment_timeout  = optional(number, 600)
    atomic              = optional(bool, false)
    cleanup_on_fail     = optional(bool, false)
    force_update        = optional(bool, false)
    recreate_pods       = optional(bool, false)

    # Namespace configuration
    namespace_labels      = optional(map(string), {})
    namespace_annotations = optional(map(string), {})

    # Server configuration
    server = object({
      service_type = optional(string, "ClusterIP")
      ingress = object({
        enabled       = optional(bool, false)
        ingress_class = optional(string, "nginx")
        hostname      = optional(string, "argocd.local")
        annotations   = optional(map(string), {})
        tls = object({
          enabled      = optional(bool, false)
          cert_manager = optional(bool, false)
        })
      })
    })

    # High availability configuration
    high_availability = object({
      enabled              = optional(bool, false)
      controller_replicas  = optional(number, 2)
      server_replicas      = optional(number, 2)
      repo_server_replicas = optional(number, 2)
    })

    # Resource configuration
    resources = object({
      controller = optional(object({
        requests = optional(object({
          memory = optional(string, "256Mi")
          cpu    = optional(string, "100m")
        }), {})
        limits = optional(object({
          memory = optional(string, "512Mi")
          cpu    = optional(string, "500m")
        }), {})
      }), {})

      server = optional(object({
        requests = optional(object({
          memory = optional(string, "128Mi")
          cpu    = optional(string, "50m")
        }), {})
        limits = optional(object({
          memory = optional(string, "256Mi")
          cpu    = optional(string, "200m")
        }), {})
      }), {})

      repo_server = optional(object({
        requests = optional(object({
          memory = optional(string, "128Mi")
          cpu    = optional(string, "50m")
        }), {})
        limits = optional(object({
          memory = optional(string, "256Mi")
          cpu    = optional(string, "200m")
        }), {})
      }), {})
    })

    # Security configuration
    security = object({
      rbac_enabled                = optional(bool, true)
      admin_password_bcrypt       = optional(string, null)
      create_initial_admin_secret = optional(bool, false)
      initial_admin_password      = optional(string, null)
    })

    # Service account for CLI access
    create_cli_service_account        = optional(bool, false)
    cli_service_account_cluster_admin = optional(bool, false)

    # Node scheduling
    node_selector = optional(map(string), {})
    tolerations = optional(list(object({
      key      = optional(string)
      operator = optional(string)
      value    = optional(string)
      effect   = optional(string)
    })), [])
    affinity = optional(object({
      nodeAffinity = optional(object({
        requiredDuringSchedulingIgnoredDuringExecution = optional(object({
          nodeSelectorTerms = list(object({
            matchExpressions = optional(list(object({
              key      = string
              operator = string
              values   = optional(list(string))
            })), [])
          }))
        }))
        preferredDuringSchedulingIgnoredDuringExecution = optional(list(object({
          weight = number
          preference = object({
            matchExpressions = optional(list(object({
              key      = string
              operator = string
              values   = optional(list(string))
            })), [])
          })
        })), [])
      }))
      podAffinity = optional(object({
        requiredDuringSchedulingIgnoredDuringExecution = optional(list(object({
          labelSelector = optional(object({
            matchExpressions = optional(list(object({
              key      = string
              operator = string
              values   = optional(list(string))
            })), [])
            matchLabels = optional(map(string))
          }))
          topologyKey = string
        })), [])
        preferredDuringSchedulingIgnoredDuringExecution = optional(list(object({
          weight = number
          podAffinityTerm = object({
            labelSelector = optional(object({
              matchExpressions = optional(list(object({
                key      = string
                operator = string
                values   = optional(list(string))
              })), [])
              matchLabels = optional(map(string))
            }))
            topologyKey = string
          })
        })), [])
      }))
      podAntiAffinity = optional(object({
        requiredDuringSchedulingIgnoredDuringExecution = optional(list(object({
          labelSelector = optional(object({
            matchExpressions = optional(list(object({
              key      = string
              operator = string
              values   = optional(list(string))
            })), [])
            matchLabels = optional(map(string))
          }))
          topologyKey = string
        })), [])
        preferredDuringSchedulingIgnoredDuringExecution = optional(list(object({
          weight = number
          podAffinityTerm = object({
            labelSelector = optional(object({
              matchExpressions = optional(list(object({
                key      = string
                operator = string
                values   = optional(list(string))
              })), [])
              matchLabels = optional(map(string))
            }))
            topologyKey = string
          })
        })), [])
      }))
    }), {})

    # Additional ArgoCD configurations
    configs = optional(map(string), {})

    # Helm values
    helm_values           = optional(map(string), {})
    helm_sensitive_values = optional(map(string), {})

    # ArgoCD Projects
    projects = optional(map(object({
      name        = string
      description = optional(string, "")
      labels      = optional(map(string), {})
      annotations = optional(map(string), {})

      source_repos = list(string)

      destinations = list(object({
        server    = string
        namespace = string
      }))

      cluster_resource_whitelist = optional(list(object({
        group = string
        kind  = string
      })), [])

      namespace_resource_whitelist = optional(list(object({
        group = string
        kind  = string
      })), [])

      roles = optional(list(object({
        name        = string
        description = optional(string, "")
        policies    = list(string)
        groups      = optional(list(string), [])
      })), [])
    })), {})

    # ArgoCD Applications
    applications = optional(map(object({
      name        = string
      labels      = optional(map(string), {})
      annotations = optional(map(string), {})
      project     = optional(string, "default")

      source = object({
        repo_url        = string
        path            = optional(string, "")
        target_revision = optional(string, "HEAD")

        helm = optional(object({
          value_files = optional(list(string), [])
          values      = optional(string, "")
        }))

        kustomize = optional(object({
          name_prefix = optional(string, "")
          name_suffix = optional(string, "")
          images      = optional(list(string), [])
        }))
      })

      destination = object({
        server    = optional(string, "https://kubernetes.default.svc")
        namespace = string
      })

      sync_policy = object({
        automated = optional(object({
          prune     = optional(bool, false)
          self_heal = optional(bool, false)
        }))

        sync_options = optional(list(string), [])

        retry = optional(object({
          limit = optional(number, 3)
          backoff = object({
            duration     = optional(string, "5s")
            factor       = optional(number, 2)
            max_duration = optional(string, "3m")
          })
        }))
      })
    })), {})
  }))

  validation {
    condition = alltrue([
      for k, v in var.argocd_deployments :
      v.security.create_initial_admin_secret == false || v.security.initial_admin_password != null
    ])
    error_message = "If create_initial_admin_secret is true, initial_admin_password must be provided."
  }

  validation {
    condition = alltrue([
      for k, v in var.argocd_deployments :
      v.server.ingress.enabled == false || v.server.ingress.hostname != null
    ])
    error_message = "If ingress is enabled, hostname must be provided."
  }
}
