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