output "id" {
description = "The ID of the Storage Account."
value       = azurerm_storage_account.this.id
}

output "name" {
description = "The name of the Storage Account."
value       = azurerm_storage_account.this.name
}

output "resource_group_name" {
description = "The name of the resource group in which the Storage Account is created."
value       = azurerm_storage_account.this.resource_group_name
}

output "location" {
description = "The Azure region where the Storage Account is created."
value       = azurerm_storage_account.this.location
}

output "primary_blob_endpoint" {
description = "The endpoint URL for blob storage in the primary location."
value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_file_endpoint" {
description = "The endpoint URL for file storage in the primary location."
value       = azurerm_storage_account.this.primary_file_endpoint
}

output "primary_table_endpoint" {
description = "The endpoint URL for table storage in the primary location."
value       = azurerm_storage_account.this.primary_table_endpoint
}

output "primary_queue_endpoint" {
description = "The endpoint URL for queue storage in the primary location."
value       = azurerm_storage_account.this.primary_queue_endpoint
}

output "primary_web_endpoint" {
description = "The endpoint URL for web storage in the primary location."
value       = azurerm_storage_account.this.primary_web_endpoint
}

output "primary_connection_string" {
description = "The connection string for the primary location."
value       = azurerm_storage_account.this.primary_connection_string
sensitive   = true
}

output "primary_access_key" {
description = "The primary access key for the storage account."
value       = var.expose_access_keys ? azurerm_storage_account.this.primary_access_key : null
sensitive   = true
}

output "secondary_access_key" {
description = "The secondary access key for the storage account."
value       = var.expose_access_keys ? azurerm_storage_account.this.secondary_access_key : null
sensitive   = true
}

output "containers" {
description = "Map of containers created within the storage account."
value       = { for c in azurerm_storage_container.containers : c.name => c.id }
}

output "storage_account_properties" {
description = "Properties of the deployed storage account."
value = {
    account_kind                    = azurerm_storage_account.this.account_kind
    account_tier                    = azurerm_storage_account.this.account_tier
    account_replication_type        = azurerm_storage_account.this.account_replication_type
    is_hns_enabled                  = azurerm_storage_account.this.is_hns_enabled
    min_tls_version                 = azurerm_storage_account.this.min_tls_version
    allow_nested_items_to_be_public = azurerm_storage_account.this.allow_nested_items_to_be_public
}
}

