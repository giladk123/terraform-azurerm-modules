# AKS Module Examples

This directory contains examples demonstrating how to use the AKS Terraform module with different configurations.

## Examples Included

### 1. Basic AKS Cluster (`basic-aks-cluster.json`)
- Simple development cluster
- Kubenet networking
- Single system node pool with auto-scaling
- Free tier for cost optimization
- Basic monitoring and security features

### 2. Advanced AKS Cluster (`advanced-aks-cluster.json`)
- Production-ready cluster with Standard tier
- Azure CNI networking with network policies
- Multiple node pools (system, worker, spot)
- Multi-zone deployment for high availability
- Advanced features: monitoring, auto-scaler, Key Vault CSI
- Comprehensive security configuration

### 3. Private AKS Cluster (`private-aks-cluster.json`)
- Private cluster with no public API endpoint
- Custom private DNS zone
- Restricted API server access
- Enhanced security configuration
- User-defined routing for outbound traffic

## Usage

### Prerequisites

1. **Azure CLI**: Authenticated with appropriate permissions
2. **Terraform**: Version >= 1.0
3. **Resource Groups**: Ensure the resource groups specified in the JSON files exist

### Quick Start

1. **Choose an example**:
   ```bash
   cd /var/home/giladk/devops/terraform-azurerm-modules/examples/aks
   ```

2. **Review and customize the JSON configuration**:
   ```bash
   # For basic cluster
   cat basic-aks-cluster.json
   
   # Edit as needed
   nano basic-aks-cluster.json
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Plan the deployment**:
   ```bash
   terraform plan
   ```

5. **Deploy**:
   ```bash
   terraform apply
   ```

### Customizing Examples

#### Modify Resource Groups
Update the `resource_group_name` fields in the JSON files:

```json
{
  "aks-dev-001": {
    "resource_group_name": "your-resource-group-name",
    "location": "your-preferred-location",
    // ... rest of configuration
  }
}
```

#### Enable/Disable Features
Most features can be toggled by modifying the JSON configuration:

```json
{
  "azure_policy_enabled": true,
  "workload_identity_enabled": true,
  "oidc_issuer_enabled": true,
  "image_cleaner_enabled": true
}
```

#### Add Monitoring
To enable Azure Monitor integration:

```json
{
  "oms_agent": {
    "log_analytics_workspace_id": "/subscriptions/YOUR_SUBSCRIPTION/resourceGroups/YOUR_RG/providers/Microsoft.OperationalInsights/workspaces/YOUR_WORKSPACE"
  }
}
```

## Example Scenarios

### Scenario 1: Development Environment
Use `basic-aks-cluster.json` for:
- Development and testing workloads
- Cost-conscious deployments
- Learning and experimentation

### Scenario 2: Production Environment
Use `advanced-aks-cluster.json` for:
- Production workloads requiring high availability
- Applications needing multiple node pools
- Environments requiring comprehensive monitoring

### Scenario 3: High-Security Environment
Use `private-aks-cluster.json` for:
- Environments with strict network security requirements
- Compliance-sensitive workloads
- Air-gapped or restricted network environments

## Deployment Examples

### Deploy Basic Cluster Only
```hcl
# In main.tf, keep only the basic example uncommented
locals {
  basic_aks_clusters = jsondecode(file("${path.module}/basic-aks-cluster.json"))
}

module "basic_aks" {
  source = "../../modules/aks"
  
  aks_clusters = local.basic_aks_clusters
}
```

### Deploy Multiple Clusters
```hcl
# Create a combined JSON file or use multiple modules
locals {
  dev_clusters = jsondecode(file("${path.module}/basic-aks-cluster.json"))
  prod_clusters = jsondecode(file("${path.module}/advanced-aks-cluster.json"))
}

module "dev_aks" {
  source = "../../modules/aks"
  aks_clusters = local.dev_clusters
}

module "prod_aks" {
  source = "../../modules/aks"
  aks_clusters = local.prod_clusters
}
```

## Post-Deployment

### Connect to Clusters
```bash
# Get credentials for the basic cluster
az aks get-credentials --resource-group rg-aks-dev-001 --name aks-dev-001

# Verify connection
kubectl get nodes

# Switch between clusters
kubectl config get-contexts
kubectl config use-context aks-dev-001
```

### Verify Deployment
```bash
# Check cluster status
kubectl cluster-info

# Check nodes
kubectl get nodes -o wide

# Check system pods
kubectl get pods -n kube-system
```

## Troubleshooting

### Common Issues

1. **Resource Group Not Found**
   ```bash
   # Create the resource group if it doesn't exist
   az group create --name rg-aks-dev-001 --location "East US"
   ```

2. **Insufficient Permissions**
   ```bash
   # Verify your permissions
   az role assignment list --assignee $(az account show --query user.name -o tsv)
   ```

3. **Quota Limits**
   ```bash
   # Check compute quotas
   az vm list-usage --location "East US" --output table
   ```

### Getting Help

- **Module Documentation**: See `../../modules/aks/README.md`
- **Azure AKS Docs**: https://docs.microsoft.com/azure/aks/
- **Terraform AzureRM Provider**: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

## Cleanup

To destroy the resources:

```bash
terraform destroy
```

**Warning**: This will delete all AKS clusters and associated resources created by these examples.

## Contributing

To add new examples:
1. Create a new JSON configuration file
2. Add corresponding documentation
3. Update this README
4. Test the example thoroughly
