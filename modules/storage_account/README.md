# Azure Storage Account Terraform Module

This module creates Azure Storage Accounts with comprehensive configuration options using a JSON-based approach for maximum flexibility and reusability.

## Features

This module supports the following Azure Storage Account features:

- **Multiple Storage Accounts**: Create multiple storage accounts using `for_each` from a single module call
- **Storage Account Types**: Support for all account kinds (StorageV2, Storage, BlobStorage, etc.)
- **Access Tiers**: Hot, Cool, and Archive tier support
- **Replication Types**: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS
- **Security Features**: 
  - HTTPS traffic only enforcement
  - Minimum TLS version configuration
  - Public blob access control
  - Network rules and firewall settings
  - Shared access key management
- **Blob Storage Features**:
  - Versioning
  - Change feed
  - Last access time tracking
  - Soft delete for blobs and containers
  - Lifecycle management policies
- **Storage Services**:
  - Blob containers
  - File shares
  - Queues
  - Tables
- **Advanced Features**:
  - Static website hosting
  - Hierarchical namespace (Data Lake Gen2)
  - NFSv3 protocol support
  - Large file shares
  - Managed identity support
  - Infrastructure encryption
  - Private endpoint connectivity

## Usage

### Basic Example

1. Create a JSON file with your storage account configurations:

```json
{
  "storageaccount001": {
    "resource_group_name": "rg-storage-prod",
    "location": "eastus",
    "account_tier": "Standard",
    "account_replication_type": "LRS",
    "tags": {
      "environment": "production",
      "department": "IT"
    }
  }
}
```

2. In your root module, use the storage account module:

```hcl
locals {
  storage_accounts = jsondecode(file("${path.module}/storage-accounts.json"))
}

module "storage_accounts" {
  source = "./modules/storage_account"
  
  storage_accounts = local.storage_accounts
}
```

### Advanced Example with All Features

```json
{
  "storageaccount001": {
    "resource_group_name": "rg-storage-prod",
    "location": "eastus",
    "account_tier": "Standard",
    "account_replication_type": "GRS",
    "account_kind": "StorageV2",
    "access_tier": "Hot",
    "enable_https_traffic_only": true,
    "min_tls_version": "TLS1_2",
    "allow_nested_items_to_be_public": false,
    "shared_access_key_enabled": true,
    "public_network_access_enabled": true,
    "tags": {
      "environment": "production",
      "department": "IT"
    },
    "blob_properties": {
      "enable_versioning": true,
      "last_access_time_enabled": true,
      "change_feed_enabled": true,
      "delete_retention_policy": {
        "enabled": true,
        "days": 30
      },
      "container_delete_retention_policy": {
        "enabled": true,
        "days": 7
      }
    },
    "network_rules": {
      "default_action": "Deny",
      "bypass": ["AzureServices"],
      "ip_rules": ["203.0.113.0/24"],
      "virtual_network_subnet_ids": ["/subscriptions/.../subnets/subnet1"]
    },
    "static_website": {
      "enabled": true,
      "index_document": "index.html",
      "error_404_document": "404.html"
    },
    "containers": {
      "data": {
        "container_access_type": "private"
      },
      "logs": {
        "container_access_type": "private",
        "metadata": {
          "retention": "30days"
        }
      }
    },
    "file_shares": {
      "share1": {
        "quota": 100,
        "access_tier": "TransactionOptimized"
      }
    },
    "queues": {
      "queue1": {
        "metadata": {
          "purpose": "processing"
        }
      }
    },
    "tables": {
      "table1": {}
    },
    "lifecycle_rules": [
      {
        "name": "archiveoldblobs",
        "enabled": true,
        "blob_types": ["blockBlob"],
        "base_blob": {
          "tier_to_cool_after_days": 30,
          "tier_to_archive_after_days": 90,
          "delete_after_days": 365
        }
      }
    ],
    "identity": {
      "type": "SystemAssigned"
    },
    "private_endpoints": {
      "blob-pe": {
        "subnet_id": "/subscriptions/.../subnets/private-endpoint-subnet",
        "subresource_names": ["blob"],
        "private_dns_zone_ids": ["/subscriptions/.../privateDnsZones/privatelink.blob.core.windows.net"],
        "tags": {
          "service": "blob-storage"
        }
      },
      "file-pe": {
        "subnet_id": "/subscriptions/.../subnets/private-endpoint-subnet",
        "subresource_names": ["file"],
        "private_dns_zone_ids": ["/subscriptions/.../privateDnsZones/privatelink.file.core.windows.net"],
        "tags": {
          "service": "file-storage"
        }
      }
    }
  },
  "datalakestore001": {
    "resource_group_name": "rg-datalake-prod",
    "location": "westus2",
    "account_tier": "Standard",
    "account_replication_type": "LRS",
    "account_kind": "StorageV2",
    "is_hns_enabled": true,
    "tags": {
      "environment": "production",
      "purpose": "datalake"
    }
  }
}
```

## JSON Configuration Schema

### Required Fields

- `resource_group_name` - The name of the resource group
- `location` - Azure region for the storage account
- `account_tier` - Performance tier (Standard or Premium)
- `account_replication_type` - Replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)

### Optional Fields with Defaults

| Field | Default | Description |
|-------|---------|-------------|
| `account_kind` | "StorageV2" | Kind of storage account |
| `access_tier` | "Hot" | Access tier for BlobStorage accounts |
| `enable_https_traffic_only` | true | Enforce HTTPS traffic only |
| `min_tls_version` | "TLS1_2" | Minimum TLS version |
| `allow_nested_items_to_be_public` | false | Allow public access to blobs |
| `shared_access_key_enabled` | true | Enable shared access keys |
| `is_hns_enabled` | false | Enable hierarchical namespace (Data Lake Gen2) |
| `nfsv3_enabled` | false | Enable NFSv3 protocol |
| `large_file_share_enabled` | false | Enable large file shares |
| `public_network_access_enabled` | true | Enable public network access |
| `tags` | {} | Resource tags |

### Complex Optional Configurations

#### Blob Properties
```json
"blob_properties": {
  "enable_versioning": false,
  "last_access_time_enabled": false,
  "change_feed_enabled": false,
  "delete_retention_policy": {
    "enabled": true,
    "days": 7
  },
  "container_delete_retention_policy": {
    "enabled": true,
    "days": 7
  }
}
```

#### Network Rules
```json
"network_rules": {
  "default_action": "Deny",
  "bypass": ["AzureServices"],
  "ip_rules": ["203.0.113.0/24"],
  "virtual_network_subnet_ids": ["/subscriptions/.../subnets/subnet1"]
}
```

#### Lifecycle Rules
```json
"lifecycle_rules": [
  {
    "name": "rule1",
    "enabled": true,
    "blob_types": ["blockBlob"],
    "base_blob": {
      "tier_to_cool_after_days": 30,
      "tier_to_archive_after_days": 90,
      "delete_after_days": 365
    },
    "snapshot": {
      "tier_to_cool_after_days": 30,
      "tier_to_archive_after_days": 90,
      "delete_after_days": 180
    }
  }
]
```

#### Private Endpoints
```json
"private_endpoints": {
  "blob-endpoint": {
    "subnet_id": "/subscriptions/.../subnets/private-endpoint-subnet",
    "subresource_names": ["blob"],
    "private_dns_zone_ids": ["/subscriptions/.../privateDnsZones/privatelink.blob.core.windows.net"],
    "tags": {
      "purpose": "blob-access"
    }
  },
  "file-endpoint": {
    "subnet_id": "/subscriptions/.../subnets/private-endpoint-subnet",
    "subresource_names": ["file"],
    "private_dns_zone_ids": ["/subscriptions/.../privateDnsZones/privatelink.file.core.windows.net"]
  }
}
```

Private endpoint configuration supports the following options:
- `subnet_id` (required) - The ID of the subnet where the private endpoint will be created
- `subresource_names` (required) - List of subresources to connect (blob, file, table, queue, web, dfs)
- `private_dns_zone_ids` (optional) - List of private DNS zone IDs for automatic DNS registration
- `private_dns_zone_group_name` (optional) - Name of the private DNS zone group (default: "default")
- `private_service_connection_name` (optional) - Custom name for the private service connection
- `is_manual_connection` (optional) - Whether the connection requires manual approval (default: false)
- `request_message` (optional) - Message for manual connection approval requests
- `tags` (optional) - Tags to apply to the private endpoint

Common subresource names for storage accounts:
- `blob` - For blob storage
- `file` - For file shares
- `table` - For table storage
- `queue` - For queue storage
- `web` - For static websites
- `dfs` - For Data Lake Storage Gen2

## Outputs

The module provides the following outputs:

- `storage_accounts` - Complete map of all storage account properties (sensitive)
- `storage_account_ids` - Map of storage account IDs
- `storage_account_names` - Map of storage account names
- `primary_blob_endpoints` - Map of primary blob endpoints
- `primary_connection_strings` - Map of primary connection strings (sensitive)
- `containers` - Map of all created containers
- `file_shares` - Map of all created file shares
- `queues` - Map of all created queues
- `tables` - Map of all created tables
- `private_endpoints` - Map of all created private endpoints
- `private_endpoint_network_interfaces` - Map of private endpoint network interface details

## Example: Accessing Outputs

```hcl
# Get a specific storage account ID
output "prod_storage_id" {
  value = module.storage_accounts.storage_account_ids["storageaccount001"]
}

# Get all blob endpoints
output "all_blob_endpoints" {
  value = module.storage_accounts.primary_blob_endpoints
}

# Get connection string (sensitive)
output "storage_connection_string" {
  value     = module.storage_accounts.primary_connection_strings["storageaccount001"]
  sensitive = true
}

# Get private endpoint information
output "storage_private_endpoints" {
  value = module.storage_accounts.private_endpoints
}

# Get specific private endpoint network interface
output "blob_private_endpoint_nic" {
  value = module.storage_accounts.private_endpoint_network_interfaces["storageaccount001-blob-pe"]
}
```

## Requirements

- Terraform >= 1.0
- AzureRM Provider >= 3.0

## Notes

1. Storage account names must be globally unique across Azure
2. Storage account names must be between 3-24 characters, lowercase letters and numbers only
3. Some features like NFSv3 have specific requirements (e.g., is_hns_enabled must be true)
4. Network rules are applied after the storage account is created
5. When using lifecycle management, ensure blob versioning is enabled if you want to manage versions
6. When using private endpoints, consider setting `public_network_access_enabled` to `false` and configuring appropriate network rules
7. Private endpoints require the subnet to have private endpoint network policies disabled
8. Each subresource type (blob, file, etc.) requires its own private endpoint 