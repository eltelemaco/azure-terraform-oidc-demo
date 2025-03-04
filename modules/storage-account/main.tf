# Azure Storage Account Module
# This module creates a storage account with blob containers and lifecycle management

locals {
# Naming convention based on best practices
storage_account_name = lower(replace(
    length(var.storage_account_custom_name) > 0 ? var.storage_account_custom_name : "${var.prefix}${var.env}${var.location_short}${var.name}${var.suffix}",
    "-", ""
))

# Ensure name meets Azure requirements (3-24 chars, lowercase alphanumeric)
valid_storage_account_name = substr(replace(local.storage_account_name, "-", ""), 0, 24)

# Default tags merged with user-provided tags
default_tags = {
    environment     = var.env
    created_by      = "terraform"
    module          = "storage-account"
    owner           = var.owner
    application     = var.application_name
    business_unit   = var.business_unit
    classification  = var.classification
}
}

# Storage Account Resource
resource "azurerm_storage_account" "this" {
name                      = local.valid_storage_account_name
resource_group_name       = var.resource_group_name
location                  = var.location
account_tier              = var.account_tier
account_replication_type  = var.replication_type
account_kind              = var.account_kind
access_tier               = var.access_tier

# Security settings
min_tls_version           = "TLS1_2"
enable_https_traffic_only = true
allow_blob_public_access  = var.allow_public_access
shared_access_key_enabled = var.shared_access_key_enabled
is_hns_enabled            = var.is_hns_enabled
nfsv3_enabled             = var.nfsv3_enabled

# Network rules
network_rules {
    default_action             = var.network_default_action
    ip_rules                   = var.ip_rules
    virtual_network_subnet_ids = var.subnet_ids
    bypass                     = var.network_bypass
}

# Blob properties with versioning, soft delete, and change feed
blob_properties {
    versioning_enabled       = var.enable_versioning
    change_feed_enabled      = var.enable_change_feed
    last_access_time_enabled = var.last_access_time_enabled
    
    container_delete_retention_policy {
    days = var.container_soft_delete_retention_days
    }
    
    delete_retention_policy {
    days = var.blob_soft_delete_retention_days
    }
}

# Identity for managed identity authentication
identity {
    type = "SystemAssigned"
}

# Tags
tags = merge(local.default_tags, var.tags)
}

# Blob Containers
resource "azurerm_storage_container" "containers" {
for_each              = { for container in var.containers : container.name => container }

name                  = each.value.name
storage_account_name  = azurerm_storage_account.this.name
container_access_type = each.value.access_type
}

# Lifecycle Management Policy
resource "azurerm_storage_management_policy" "lifecycle" {
count = length(var.lifecycle_rules) > 0 ? 1 : 0

storage_account_id = azurerm_storage_account.this.id

dynamic "rule" {
    for_each = var.lifecycle_rules
    
    content {
    name    = rule.value.name
    enabled = rule.value.enabled
    
    filters {
        prefix_match = rule.value.prefix_match
        blob_types   = rule.value.blob_types
    }
    
    actions {
        dynamic "base_blob" {
        for_each = rule.value.actions.base_blob != null ? [rule.value.actions.base_blob] : []
        
        content {
            tier_to_cool_after_days_since_modification_greater_than        = lookup(base_blob.value, "tier_to_cool_after_days", null)
            tier_to_archive_after_days_since_modification_greater_than     = lookup(base_blob.value, "tier_to_archive_after_days", null)
            delete_after_days_since_modification_greater_than              = lookup(base_blob.value, "delete_after_days", null)
        }
        }
        
        dynamic "snapshot" {
        for_each = rule.value.actions.snapshot != null ? [rule.value.actions.snapshot] : []
        
        content {
            delete_after_days_since_creation_greater_than = lookup(snapshot.value, "delete_after_days", null)
        }
        }
        
        dynamic "version" {
        for_each = rule.value.actions.version != null ? [rule.value.actions.version] : []
        
        content {
            delete_after_days_since_creation = lookup(version.value, "delete_after_days", null)
        }
        }
    }
    }
}
}

# Diagnostic Settings for Monitoring
resource "azurerm_monitor_diagnostic_setting" "storage_diagnostics" {
count = var.enable_diagnostics ? 1 : 0

name                       = "${local.valid_storage_account_name}-diagnostics"
target_resource_id         = azurerm_storage_account.this.id
log_analytics_workspace_id = var.log_analytics_workspace_id

# Metric configuration
metric {
    category = "Transaction"
    enabled  = true
    
    retention_policy {
    enabled = true
    days    = 30
    }
}

# Logging configuration for all available log categories
enabled_log {
    category = "StorageRead"
}

enabled_log {
    category = "StorageWrite"
}

enabled_log {
    category = "StorageDelete"
}
}

