# Azure Kubernetes Service (AKS) Terraform Module

This module creates and manages Azure Kubernetes Service (AKS) clusters with comprehensive configuration options, following best practices for production deployments.

## Recent Updates

### v3.116.0 (Latest)
- ✅ **Updated AzureRM Provider**: Now using version `3.116.0` (Microsoft recommended)
- ✅ **Modern Azure AD Integration**: Updated to use AKS-managed Entra Integration (removes legacy deprecation warnings)
- ✅ **Kubernetes Version**: Updated examples to use `1.30.6` (stable, Free tier compatible)
- ✅ **Load Balancer**: Standard Load Balancer required for availability zones support
- ✅ **API Stability**: Uses stable Azure APIs instead of preview versions

## Features

- ✅ **Reusable and Configurable**: JSON-based configuration for maximum flexibility
- ✅ **Multiple Node Pools**: Support for system and user node pools with different configurations
- ✅ **Advanced Networking**: Support for Azure CNI, Kubenet, and network policies
- ✅ **Security**: Integration with Azure AD, RBAC, private clusters, and network security groups
- ✅ **Monitoring**: Built-in support for Azure Monitor and Log Analytics
- ✅ **Auto Scaling**: Cluster and horizontal pod autoscaling capabilities
- ✅ **Add-ons**: Support for various AKS add-ons like Azure Policy, Key Vault CSI driver, and more
- ✅ **High Availability**: Multi-zone deployment support
- ✅ **Maintenance Windows**: Configurable maintenance windows for upgrades

## Resources Created

This module creates the following Azure resources:

- **azurerm_kubernetes_cluster**: The main AKS cluster
- **azurerm_kubernetes_cluster_node_pool**: Additional node pools (optional)

## Usage

### Basic Usage

```hcl
# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Load AKS configurations from JSON
locals {
  aks_clusters = jsondecode(file("${path.module}/aks-clusters.json"))
}

# Create AKS clusters
module "aks" {
  source = "./modules/aks"
  
  aks_clusters = local.aks_clusters
}
```

### JSON Configuration Examples

#### Basic AKS Cluster

```json
{
  "aks-dev-001": {
    "resource_group_name": "rg-aks-dev-001",
    "location": "East US",
    "dns_prefix": "aks-dev-001",
    "kubernetes_version": "1.30.6",
    "sku_tier": "Free",
    "identity": {
      "type": "SystemAssigned"
    },
    "default_node_pool": {
      "name": "system",
      "vm_size": "Standard_DS2_v2",
      "node_count": 2,
      "auto_scaling_enabled": true,
      "min_count": 1,
      "max_count": 3,
      "upgrade_settings": {
        "max_surge": "1"
      }
    },
    "network_profile": {
      "network_plugin": "kubenet",
      "service_cidr": "10.0.0.0/16",
      "dns_service_ip": "10.0.0.10",
      "pod_cidr": "10.244.0.0/16"
    },
    "tags": {
      "Environment": "Development",
      "ManagedBy": "Terraform"
    }
  }
}
```

#### Advanced Production AKS Cluster

```json
{
  "aks-prod-001": {
    "resource_group_name": "rg-aks-prod-001",
    "location": "East US",
    "dns_prefix": "aks-prod-001",
    "kubernetes_version": "1.30.6",
    "sku_tier": "Standard",
    "identity": {
      "type": "SystemAssigned"
    },
    "default_node_pool": {
      "name": "system",
      "vm_size": "Standard_DS2_v2",
      "node_count": 3,
      "auto_scaling_enabled": true,
      "min_count": 3,
      "max_count": 10,
      "zones": ["1", "2", "3"],
      "only_critical_addons_enabled": true,
      "upgrade_settings": {
        "max_surge": "33%"
      }
    },
    "node_pools": {
      "worker": {
        "vm_size": "Standard_DS3_v2",
        "auto_scaling_enabled": true,
        "min_count": 3,
        "max_count": 20,
        "zones": ["1", "2", "3"],
        "mode": "User"
      }
    },
    "network_profile": {
      "network_plugin": "azure",
      "network_policy": "azure",
      "service_cidr": "10.0.0.0/16",
      "dns_service_ip": "10.0.0.10"
    },
    "azure_active_directory_role_based_access_control": {
      "managed": true,
      "azure_rbac_enabled": false,
      "admin_group_object_ids": ["group-id-here"]
    },
    "oms_agent": {
      "log_analytics_workspace_id": "/subscriptions/.../workspaces/law-monitoring"
    },
    "automatic_upgrade_channel": "stable",
    "azure_policy_enabled": true,
    "workload_identity_enabled": true,
    "oidc_issuer_enabled": true
  }
}
```

## Configuration Reference

### Required Variables

| Name | Type | Description |
|------|------|-------------|
| `aks_clusters` | `map(object)` | Map of AKS cluster configurations |

### AKS Cluster Configuration

#### Basic Configuration

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `resource_group_name` | `string` | Yes | - | Resource group name where the AKS cluster will be created |
| `location` | `string` | Yes | - | Azure region for the AKS cluster |
| `dns_prefix` | `string` | No | - | DNS prefix for the cluster |
| `kubernetes_version` | `string` | No | Latest | Kubernetes version |
| `sku_tier` | `string` | No | `"Free"` | AKS SKU tier (`Free`, `Standard`, `Premium`) |

#### Identity Configuration

```json
"identity": {
  "type": "SystemAssigned"
}
```

Or for user-assigned identity:

```json
"identity": {
  "type": "UserAssigned",
  "identity_ids": ["/subscriptions/.../resourceGroups/.../providers/Microsoft.ManagedIdentity/userAssignedIdentities/..."]
}
```

#### Default Node Pool Configuration

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | `string` | Yes | - | Node pool name |
| `vm_size` | `string` | Yes | - | VM size for nodes |
| `node_count` | `number` | No | `1` | Initial number of nodes |
| `auto_scaling_enabled` | `bool` | No | `false` | Enable auto-scaling |
| `min_count` | `number` | No | - | Minimum nodes (required if auto-scaling enabled) |
| `max_count` | `number` | No | - | Maximum nodes (required if auto-scaling enabled) |
| `max_pods` | `number` | No | - | Maximum pods per node |
| `os_disk_size_gb` | `number` | No | - | OS disk size in GB |
| `os_disk_type` | `string` | No | `"Managed"` | OS disk type (`Managed`, `Ephemeral`) |
| `os_sku` | `string` | No | `"Ubuntu"` | OS SKU (`Ubuntu`, `AzureLinux`, `Windows2019`, `Windows2022`) |
| `zones` | `list(string)` | No | - | Availability zones |

#### Additional Node Pools

```json
"node_pools": {
  "worker": {
    "vm_size": "Standard_DS3_v2",
    "auto_scaling_enabled": true,
    "min_count": 3,
    "max_count": 20,
    "mode": "User",
    "node_labels": {
      "workload": "general"
    }
  },
  "spot": {
    "vm_size": "Standard_DS2_v2",
    "priority": "Spot",
    "eviction_policy": "Delete",
    "spot_max_price": -1,
    "node_taints": ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"]
  }
}
```

#### Network Profile Configuration

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `network_plugin` | `string` | `"kubenet"` | Network plugin (`kubenet`, `azure`, `none`) |
| `network_policy` | `string` | - | Network policy (`azure`, `calico`, `cilium`) |
| `service_cidr` | `string` | - | Service address CIDR |
| `dns_service_ip` | `string` | - | DNS service IP |
| `pod_cidr` | `string` | - | Pod CIDR (kubenet only) |
| `load_balancer_sku` | `string` | `"standard"` | Load balancer SKU |
| `outbound_type` | `string` | `"loadBalancer"` | Outbound routing method |

#### Security Configuration

##### Azure AD Integration (Modern AKS-managed Entra Integration)

```json
"azure_active_directory_role_based_access_control": {
  "managed": true,
  "azure_rbac_enabled": false,
  "admin_group_object_ids": ["group-id-1", "group-id-2"],
  "tenant_id": null
}
```

> **Note**: For development environments, you can omit the `azure_active_directory_role_based_access_control` configuration entirely to use standard Kubernetes RBAC without Azure AD integration.

##### Private Cluster

```json
"private_cluster_enabled": true,
"private_dns_zone_id": "/subscriptions/.../resourceGroups/.../providers/Microsoft.Network/privateDnsZones/...",
"api_server_access_profile": {
  "authorized_ip_ranges": ["10.0.0.0/8"]
}
```

#### Add-ons Configuration

##### Azure Monitor

```json
"oms_agent": {
  "log_analytics_workspace_id": "/subscriptions/.../workspaces/law-monitoring",
  "msi_auth_for_monitoring_enabled": true
}
```

##### Key Vault Secrets Provider

```json
"key_vault_secrets_provider": {
  "secret_rotation_enabled": true,
  "secret_rotation_interval": "2m"
}
```

##### Application Gateway Ingress Controller

```json
"ingress_application_gateway": {
  "subnet_id": "/subscriptions/.../subnets/subnet-agw"
}
```

#### Maintenance Windows

```json
"maintenance_window": {
  "allowed": [
    {
      "day": "Sunday",
      "hours": [2, 3, 4]
    }
  ]
}
```

## Outputs

| Name | Type | Description |
|------|------|-------------|
| `aks_clusters` | `map(object)` | Complete AKS cluster information (sensitive) |
| `aks_cluster_ids` | `map(string)` | Map of cluster names to resource IDs |
| `aks_cluster_names` | `map(string)` | Map of cluster keys to actual names |
| `aks_cluster_fqdns` | `map(string)` | Map of cluster FQDNs |
| `kube_configs` | `map(string)` | Kubeconfig contents (sensitive) |
| `oidc_issuer_urls` | `map(string)` | OIDC issuer URLs |
| `node_resource_groups` | `map(string)` | Node resource group names |
| `additional_node_pools` | `map(object)` | Additional node pool information |

## Examples

The module includes several example configurations in the `../../examples/aks/` directory:

- **basic-aks-cluster.json**: Simple development cluster
- **advanced-aks-cluster.json**: Production cluster with multiple node pools
- **private-aks-cluster.json**: Private cluster configuration
- **main.tf**: Example Terraform configuration showing how to use the module
- **outputs.tf**: Example outputs for accessing cluster information

For complete usage examples, see the [examples directory](../../examples/aks/).

## Best Practices

### Security

1. **Use System-Assigned Managed Identity**: Recommended over service principals
2. **Enable Azure AD Integration**: Use Azure RBAC for Kubernetes authorization
3. **Private Clusters**: For production workloads, consider private clusters
4. **Network Policies**: Enable network policies for pod-to-pod communication control
5. **Authorized IP Ranges**: Restrict API server access to specific IP ranges

### High Availability

1. **Multi-Zone Deployment**: Distribute nodes across availability zones
2. **Multiple Node Pools**: Separate system and user workloads
3. **Auto-Scaling**: Enable cluster and pod auto-scaling
4. **Standard SKU**: Use Standard tier for SLA guarantees

### Monitoring and Maintenance

1. **Azure Monitor Integration**: Enable container insights
2. **Log Analytics**: Configure log forwarding
3. **Maintenance Windows**: Schedule maintenance during off-peak hours
4. **Automatic Upgrades**: Enable automatic channel upgrades

### Performance

1. **Node Pool Sizing**: Right-size VM SKUs for workloads
2. **Spot Instances**: Use spot node pools for cost optimization
3. **Storage Classes**: Configure appropriate storage classes
4. **Resource Limits**: Set appropriate resource requests and limits

## Troubleshooting

### Common Issues

1. **Insufficient Subnet Size**: Ensure subnet has enough IP addresses
2. **Service Principal Permissions**: Verify identity has required permissions
3. **Network Connectivity**: Check NSG rules and route tables for private clusters
4. **Quota Limits**: Verify Azure subscription quotas

### Debugging

1. Check AKS cluster events: `kubectl get events --sort-by=.metadata.creationTimestamp`
2. View cluster logs: Use Azure Monitor container insights
3. Check node status: `kubectl get nodes -o wide`
4. Verify network connectivity: Test from within pods

## Troubleshooting

### Common Issues and Solutions

#### 1. Azure AD Integration Deprecation Warning
**Error**: `Azure AD Integration (legacy) is deprecated`
**Solution**: Use modern AKS-managed Entra Integration:
```json
"azure_active_directory_role_based_access_control": {
  "managed": true,
  "azure_rbac_enabled": false
}
```
**Note**: Remove legacy parameters (`client_app_id`, `server_app_id`, `server_app_secret`)

#### 2. Load Balancer SKU Error
**Error**: `SLBRequiredForAvailabilityZone`
**Solution**: Use Standard Load Balancer when using availability zones:
```json
"network_profile": {
  "load_balancer_sku": "standard"
},
"default_node_pool": {
  "zones": ["1", "2", "3"]
}
```

#### 3. Kubernetes Version Not Supported
**Error**: `K8sVersionNotSupported` - LTS versions require Premium tier
**Solution**: Use standard supported versions with Free tier:
```json
"kubernetes_version": "1.30.6",
"sku_tier": "Free"
```

#### 4. Provider Version Conflicts
**Error**: Version constraint conflicts between modules
**Solution**: Use consistent provider version across all modules:
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
  }
}
```

#### 5. Node Pool OS Disk Type Error
**Error**: `expected default_node_pool.0.os_disk_type to be one of ["Ephemeral" "Managed"]`
**Solution**: Use valid disk types:
```json
"default_node_pool": {
  "os_disk_type": "Managed"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | 3.116.0 |

## Contributing

When contributing to this module:

1. Follow Terraform best practices
2. Update documentation for any new features
3. Include example configurations
4. Test with multiple scenarios
5. Ensure backward compatibility

## License

This module is licensed under the MIT License. See LICENSE file for details.
