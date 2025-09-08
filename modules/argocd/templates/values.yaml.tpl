# ArgoCD Helm Chart Values Template
# This template is used by Terraform to generate values.yaml for ArgoCD deployment

global:
  # Global image settings
  image:
    tag: ""  # Use chart default

# ArgoCD Server Configuration
server:
  # Server replicas
  replicas: ${server_replicas}
  
  # Service configuration
  service:
    type: ${server_service_type}
    
  # Ingress configuration
  ingress:
    enabled: ${server_ingress_enabled}
    ingressClassName: ${server_ingress_class}
    hostname: ${server_ingress_hostname}
    tls: ${server_ingress_tls_enabled}
    annotations: ${server_ingress_annotations}
    %{ if server_ingress_cert_manager ~}
    tls:
      - secretName: argocd-server-tls
        hosts:
          - ${server_ingress_hostname}
    %{ endif ~}
  
  # Resource configuration
  resources: ${server_resources}
  
  # Node scheduling
  nodeSelector: ${node_selector}
  tolerations: ${tolerations}
  affinity: ${affinity}
  
  # Additional server configuration
  config:
    # RBAC configuration
    policy.default: role:readonly
    policy.csv: |
      p, role:admin, applications, *, */*, allow
      p, role:admin, clusters, *, *, allow
      p, role:admin, repositories, *, *, allow
      g, argocd-admins, role:admin

# ArgoCD Application Controller Configuration
controller:
  # Controller replicas
  replicas: ${controller_replicas}
  
  # Resource configuration
  resources: ${controller_resources}
  
  # Node scheduling
  nodeSelector: ${node_selector}
  tolerations: ${tolerations}
  affinity: ${affinity}

# ArgoCD Repository Server Configuration
repoServer:
  # Repository server replicas
  replicas: ${repo_server_replicas}
  
  # Resource configuration
  resources: ${repo_server_resources}
  
  # Node scheduling
  nodeSelector: ${node_selector}
  tolerations: ${tolerations}
  affinity: ${affinity}

# ArgoCD Notifications Controller
notifications:
  enabled: false  # Can be enabled via additional configs

# ArgoCD ApplicationSet Controller
applicationSet:
  enabled: true
  
  # Resource configuration
  resources:
    requests:
      memory: "128Mi"
      cpu: "50m"
    limits:
      memory: "256Mi"
      cpu: "200m"
  
  # Node scheduling
  nodeSelector: ${node_selector}
  tolerations: ${tolerations}
  affinity: ${affinity}

# Redis Configuration (for HA setups)
redis:
  enabled: true
  
# Redis HA Configuration (for production)
redis-ha:
  enabled: false  # Enable for HA setups
  
# External Redis (if using external Redis)
externalRedis:
  host: ""
  port: 6379
  
# RBAC Configuration
rbac:
  create: ${enable_rbac}
  
# Service Account Configuration
serviceAccount:
  create: true
  
# Security Context
securityContext:
  runAsNonRoot: true
  runAsUser: 999
  fsGroup: 999

# Additional configurations
configs:
  # Additional configuration files can be added here
  %{ for key, value in configs }
  ${key}: |
    ${value}
  %{ endfor }

# Custom resource definitions
crds:
  install: true
  keep: false

# Metrics and monitoring
metrics:
  enabled: false  # Enable if using Prometheus
  service:
    annotations: {}
  serviceMonitor:
    enabled: false

# Dex (OIDC) configuration
dex:
  enabled: false  # Enable for OIDC integration
