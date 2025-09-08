# ArgoCD Terraform Module

This module deploys ArgoCD (Argo Continuous Delivery) on Kubernetes clusters using Helm, following best practices for production deployments. ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes that automates the deployment of applications to your cluster.

## Features

- ✅ **Flexible Deployment**: Support for single instance or high-availability setups
- ✅ **Ingress Integration**: Built-in support for ingress controllers with TLS
- ✅ **Resource Management**: Configurable resource requests and limits
- ✅ **Security**: RBAC, service accounts, and secure secret management
- ✅ **GitOps Ready**: Pre-configured projects and applications support
- ✅ **Node Scheduling**: Support for node selectors, tolerations, and affinity
- ✅ **CLI Integration**: Service account for CI/CD pipeline integration
- ✅ **Monitoring Ready**: Prepared for Prometheus metrics integration

## Prerequisites

- **Kubernetes cluster** (AKS, EKS, GKE, or any Kubernetes distribution)
- **Terraform providers**:
  - `hashicorp/kubernetes` ~> 2.23
  - `hashicorp/helm` ~> 2.11
- **Ingress controller** (if using ingress) - NGINX, Traefik, etc.
- **Cert-Manager** (optional, for automatic TLS certificates)
- **Helm** installed locally (for CLI operations)
- **kubectl** configured to access your cluster

## Usage

### Basic ArgoCD Deployment

```hcl
# Configure providers
provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

# Deploy ArgoCD
module "argocd" {
  source = "./modules/argocd"
  
  argocd_deployments = {
    "production" = {
      namespace    = "argocd"
      release_name = "argocd"
      
      server = {
        service_type = "ClusterIP"
        ingress = {
          enabled       = true
          ingress_class = "nginx"
          hostname      = "argocd.example.com"
          tls = {
            enabled      = true
            cert_manager = true
          }
          annotations = {
            "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
            "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
            "nginx.ingress.kubernetes.io/backend-protocol" = "GRPC"
          }
        }
      }
      
      security = {
        rbac_enabled = true
      }
    }
  }
}
```

### High Availability Deployment

```hcl
module "argocd" {
  source = "./modules/argocd"
  
  argocd_deployments = {
    "production-ha" = {
      namespace    = "argocd"
      release_name = "argocd"
      
      # Enable HA
      high_availability = {
        enabled              = true
        controller_replicas  = 2
        server_replicas      = 2
        repo_server_replicas = 2
      }
      
      # Resource configuration for production
      resources = {
        controller = {
          requests = {
            memory = "512Mi"
            cpu    = "200m"
          }
          limits = {
            memory = "1Gi"
            cpu    = "500m"
          }
        }
        server = {
          requests = {
            memory = "256Mi"
            cpu    = "100m"
          }
          limits = {
            memory = "512Mi"
            cpu    = "300m"
          }
        }
        repo_server = {
          requests = {
            memory = "256Mi"
            cpu    = "100m"
          }
          limits = {
            memory = "512Mi"
            cpu    = "300m"
          }
        }
      }
      
      server = {
        service_type = "ClusterIP"
        ingress = {
          enabled       = true
          ingress_class = "nginx"
          hostname      = "argocd.company.com"
          tls = {
            enabled      = true
            cert_manager = true
          }
          annotations = {
            "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
            "nginx.ingress.kubernetes.io/backend-protocol" = "GRPC"
          }
        }
      }
      
      # Node scheduling for production
      node_selector = {
        "kubernetes.io/os" = "linux"
      }
      
      tolerations = [
        {
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
          effect   = "NoSchedule"
        }
      ]
      
      security = {
        rbac_enabled                 = true
        create_initial_admin_secret  = true
        initial_admin_password       = "your-secure-password"
      }
      
      # CLI service account for CI/CD
      create_cli_service_account        = true
      cli_service_account_cluster_admin = true
    }
  }
}
```

### ArgoCD with Projects and Applications

```hcl
module "argocd" {
  source = "./modules/argocd"
  
  argocd_deployments = {
    "gitops" = {
      namespace    = "argocd"
      release_name = "argocd"
      
      server = {
        service_type = "ClusterIP"
        ingress = {
          enabled       = true
          ingress_class = "nginx"
          hostname      = "argocd.internal.com"
          tls = {
            enabled = false
          }
        }
      }
      
      # Define ArgoCD Projects
      projects = {
        "web-apps" = {
          name        = "web-applications"
          description = "Web applications project"
          
          source_repos = [
            "https://github.com/company/web-apps.git",
            "https://github.com/company/helm-charts.git"
          ]
          
          destinations = [
            {
              server    = "https://kubernetes.default.svc"
              namespace = "web-*"
            },
            {
              server    = "https://kubernetes.default.svc"
              namespace = "staging"
            }
          ]
          
          cluster_resource_whitelist = [
            {
              group = ""
              kind  = "Namespace"
            }
          ]
          
          roles = [
            {
              name     = "developer"
              policies = ["p, proj:web-applications:developer, applications, get, web-applications/*, allow"]
              groups   = ["company:developers"]
            }
          ]
        }
      }
      
      # Define ArgoCD Applications
      applications = {
        "frontend-app" = {
          name    = "frontend"
          project = "web-applications"
          
          source = {
            repo_url        = "https://github.com/company/frontend-app.git"
            path            = "k8s/overlays/production"
            target_revision = "main"
            
            kustomize = {
              name_prefix = "prod-"
            }
          }
          
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "web-frontend"
          }
          
          sync_policy = {
            automated = {
              prune     = true
              self_heal = true
            }
            
            sync_options = [
              "CreateNamespace=true",
              "PrunePropagationPolicy=foreground"
            ]
            
            retry = {
              limit = 3
              backoff = {
                duration     = "5s"
                factor       = 2
                max_duration = "3m"
              }
            }
          }
        }
        
        "backend-api" = {
          name    = "api-backend"
          project = "web-applications"
          
          source = {
            repo_url        = "https://github.com/company/helm-charts.git"
            path            = "charts/backend-api"
            target_revision = "v1.2.0"
            
            helm = {
              value_files = ["values-production.yaml"]
              values = <<-EOT
                image:
                  tag: "v2.1.0"
                replicas: 3
                resources:
                  requests:
                    memory: "256Mi"
                    cpu: "100m"
              EOT
            }
          }
          
          destination = {
            server    = "https://kubernetes.default.svc"
            namespace = "web-backend"
          }
          
          sync_policy = {
            automated = {
              prune     = false
              self_heal = true
            }
            sync_options = ["CreateNamespace=true"]
          }
        }
      }
      
      security = {
        rbac_enabled = true
      }
    }
  }
}
```

## Configuration Reference

### Required Variables

| Name | Type | Description |
|------|------|-------------|
| `argocd_deployments` | `map(object)` | Map of ArgoCD deployment configurations |

### ArgoCD Deployment Configuration

#### Basic Settings

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `namespace` | `string` | Yes | - | Kubernetes namespace for ArgoCD |
| `release_name` | `string` | Yes | - | Helm release name |
| `chart_repository` | `string` | No | `"https://argoproj.github.io/argo-helm"` | Helm chart repository |
| `chart_name` | `string` | No | `"argo-cd"` | Helm chart name |
| `chart_version` | `string` | No | `"5.51.6"` | Helm chart version |

#### Server Configuration

```hcl
server = {
  service_type = "ClusterIP"  # ClusterIP, LoadBalancer, NodePort
  ingress = {
    enabled       = true
    ingress_class = "nginx"
    hostname      = "argocd.example.com"
    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
    }
    tls = {
      enabled      = true
      cert_manager = true  # Use cert-manager for TLS
    }
  }
}
```

#### High Availability

```hcl
high_availability = {
  enabled              = true
  controller_replicas  = 2    # Application controller replicas
  server_replicas      = 2    # Server replicas
  repo_server_replicas = 2    # Repository server replicas
}
```

#### Resource Configuration

```hcl
resources = {
  controller = {
    requests = { memory = "512Mi", cpu = "200m" }
    limits   = { memory = "1Gi", cpu = "500m" }
  }
  server = {
    requests = { memory = "256Mi", cpu = "100m" }
    limits   = { memory = "512Mi", cpu = "300m" }
  }
  repo_server = {
    requests = { memory = "256Mi", cpu = "100m" }
    limits   = { memory = "512Mi", cpu = "300m" }
  }
}
```

#### Security Configuration

```hcl
security = {
  rbac_enabled                 = true
  admin_password_bcrypt        = "$2a$10$..."  # bcrypt hash
  create_initial_admin_secret  = true
  initial_admin_password       = "secure-password"
}
```

#### Node Scheduling

```hcl
node_selector = {
  "kubernetes.io/os" = "linux"
}

tolerations = [
  {
    key      = "node-role.kubernetes.io/control-plane"
    operator = "Exists"
    effect   = "NoSchedule"
  }
]

affinity = {
  podAntiAffinity = {
    preferredDuringSchedulingIgnoredDuringExecution = [
      {
        weight = 100
        podAffinityTerm = {
          labelSelector = {
            matchLabels = {
              "app.kubernetes.io/name" = "argocd-server"
            }
          }
          topologyKey = "kubernetes.io/hostname"
        }
      }
    ]
  }
}
```

### Projects Configuration

```hcl
projects = {
  "project-name" = {
    name        = "my-project"
    description = "Project description"
    
    source_repos = [
      "https://github.com/org/repo1.git",
      "https://github.com/org/repo2.git"
    ]
    
    destinations = [
      {
        server    = "https://kubernetes.default.svc"
        namespace = "production"
      }
    ]
    
    cluster_resource_whitelist = [
      { group = "", kind = "Namespace" },
      { group = "rbac.authorization.k8s.io", kind = "ClusterRole" }
    ]
    
    roles = [
      {
        name     = "developer"
        policies = ["p, proj:my-project:developer, applications, get, my-project/*, allow"]
        groups   = ["company:developers"]
      }
    ]
  }
}
```

### Applications Configuration

```hcl
applications = {
  "app-name" = {
    name    = "my-application"
    project = "my-project"
    
    source = {
      repo_url        = "https://github.com/org/app.git"
      path            = "manifests"
      target_revision = "main"
      
      # For Helm applications
      helm = {
        value_files = ["values.yaml", "values-prod.yaml"]
        values = "image.tag: v1.0.0"
      }
      
      # For Kustomize applications
      kustomize = {
        name_prefix = "prod-"
        images = ["nginx:1.20"]
      }
    }
    
    destination = {
      server    = "https://kubernetes.default.svc"
      namespace = "production"
    }
    
    sync_policy = {
      automated = {
        prune     = true
        self_heal = true
      }
      sync_options = ["CreateNamespace=true"]
      retry = {
        limit = 3
        backoff = {
          duration     = "5s"
          factor       = 2
          max_duration = "3m"
        }
      }
    }
  }
}
```

## Outputs

| Name | Type | Description |
|------|------|-------------|
| `argocd_deployments` | `map(object)` | ArgoCD deployment information |
| `argocd_namespaces` | `map(string)` | Namespace names |
| `argocd_server_urls` | `map(object)` | Server URLs (internal/external) |
| `argocd_cli_connection_info` | `map(object)` | CLI connection information |
| `argocd_service_accounts` | `map(object)` | Service account information |
| `argocd_projects` | `map(object)` | Created project information |
| `argocd_applications` | `map(object)` | Created application information |

## Post-Deployment

### Accessing ArgoCD UI

#### With Ingress
```bash
# Access via configured hostname
https://argocd.example.com
```

#### Without Ingress (Port Forward)
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Access at https://localhost:8080
```

### ArgoCD CLI Setup

```bash
# Install ArgoCD CLI
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argocd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd

# Login to ArgoCD
argocd login argocd.example.com

# Or with port-forward
argocd login localhost:8080
```

### Initial Admin Password

```bash
# Get initial admin password (if not set via initial_admin_password)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Best Practices

### Security
1. **Use HTTPS**: Always enable TLS for production deployments
2. **RBAC**: Configure proper RBAC policies and projects
3. **Secrets Management**: Use external secret management for sensitive data
4. **Network Policies**: Implement network policies to restrict traffic

### High Availability
1. **Multiple Replicas**: Use HA configuration for production
2. **Pod Disruption Budgets**: Configure PDBs for critical components
3. **Anti-Affinity**: Spread replicas across different nodes
4. **Resource Limits**: Set appropriate resource requests and limits

### GitOps
1. **Project Organization**: Use ArgoCD projects to organize applications
2. **Repository Structure**: Follow GitOps repository structure best practices
3. **Automated Sync**: Enable automated sync for non-critical environments
4. **Sync Policies**: Configure appropriate sync policies and options

### Monitoring
1. **Metrics**: Enable Prometheus metrics for monitoring
2. **Alerts**: Set up alerts for application sync failures
3. **Logging**: Configure centralized logging for ArgoCD components

## Troubleshooting

### Common Issues

1. **Ingress Not Working**
   - Check ingress controller is installed and running
   - Verify DNS resolution for hostname
   - Check ingress annotations for your ingress controller

2. **Applications Not Syncing**
   - Verify repository access and credentials
   - Check ArgoCD project permissions
   - Review application sync policies

3. **High Memory Usage**
   - Increase resource limits for repo-server
   - Consider using resource exclusions for large repositories
   - Implement resource quotas

4. **Certificate Issues**
   - Verify cert-manager is installed and configured
   - Check certificate issuer configuration
   - Review TLS secret creation

### Debugging Commands

```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# View ArgoCD server logs
kubectl logs -n argocd deployment/argocd-server

# Check application status
kubectl get applications -n argocd

# View application details
kubectl describe application <app-name> -n argocd
```

## Examples

See the `examples/` directory for complete working examples:

- **basic-argocd**: Simple ArgoCD deployment
- **ha-argocd**: High availability setup
- **gitops-complete**: Full GitOps setup with projects and applications

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| kubernetes | ~> 2.23 |
| helm | ~> 2.11 |

## Provider Configuration

### Kubernetes Provider

The module requires the Kubernetes provider to be configured with proper cluster credentials. For AKS clusters, use the following configuration:

```hcl
provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}
```

### Helm Provider

The Helm provider must be configured with the same Kubernetes credentials:

```hcl
provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}
```

> **Note**: The `kubernetes` block inside the `helm` provider is the correct syntax according to the official Terraform Helm provider documentation.

## Contributing

1. Follow Terraform best practices
2. Update documentation for new features
3. Include examples for new functionality
4. Test with different Kubernetes distributions
5. Ensure backward compatibility

## License

This module is licensed under the MIT License.
