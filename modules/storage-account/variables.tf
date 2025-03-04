variable "resource_group_name" {
type        = string
description = "The name of the resource group in which to create the storage account."
}

variable "location" {
type        = string
description = "The Azure Region where the storage account should exist."
}

variable "name_prefix" {
type        = string
description = "Prefix to use for the storage account name. Combined with a suffix to form the full storage account name."
default     = "st"
}

variable "name_suffix" {
type        = string
description = "Suffix to append to the storage account name. Will be combined with name_prefix."
default     = ""
}

variable "account_kind" {
type        = string
description = "The kind of storage account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
default     = "StorageV2"
validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "The account_kind must be one of BlobStorage, BlockBlobStorage, FileStorage, Storage or StorageV2."
}
}

variable "account_tier" {
type        = string
description = "The account tier to use. Valid options are Standard and Premium."
default     = "Standard"
validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "The account_tier must be either Standard or Premium."
}
}

variable "account_replication_type" {
type        = string
description = "The type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
default     = "ZRS"
validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "The account_replication_type must be one of LRS, GRS, RAGRS, ZRS, GZRS or RAGZRS."
}
}

variable "access_tier" {
type        = string
description = "The access tier for BlobStorage and StorageV2 accounts. Valid options are Hot and Cool."
default     = "Hot"
validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "The access_tier must be either Hot or Cool."
}
}

variable "min_tls_version" {
type        = string
description = "The minimum supported TLS version for the storage account."
default     = "TLS1_2"
validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "The min_tls_version must be one of TLS1_0, TLS1_1 or TLS1_2."
}
}

variable "enable_https_traffic_only" {
type        = bool
description = "Boolean flag which forces HTTPS if enabled."
default     = true
}

variable "allow_blob_public_access" {
type        = bool
description = "Allow or disallow public access to all blobs or containers in the storage account."
default     = false
}

variable "shared_access_key_enabled" {
type        = bool
description = "Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key."
default     = true
}

variable "is_hns_enabled" {
type        = bool
description = "Is Hierarchical Namespace enabled? This is required for Azure Data Lake Storage Gen 2."
default     = false
}

variable "nfsv3_enabled" {
type        = bool
description = "Is NFSv3 protocol enabled? Changing this forces a new resource to be created."
default     = false
}

variable "network_rules" {
type = object({
    default_action             = string
    bypass                     = list(string)
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
})
description = "Object with network rule configuration."
default = {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = []
    virtual_network_subnet_ids = []
}
validation {
    condition     = contains(["Allow", "Deny"], var.network_rules.default_action)
    error_message = "The default_action must be either Allow or Deny."
}
}

variable "blob_containers" {
type = list(object({
    name                  = string
    container_access_type = string
    metadata              = map(string)
}))
description = "List of blob containers to create within the storage account."
default     = []
validation {
    condition = alltrue([
    for container in var.blob_containers :
    contains(["private", "blob", "container"], container.container_access_type)
    ])
    error_message = "The container_access_type must be one of 'private', 'blob', or 'container'."
}
}

variable "lifecycle_rules" {
type = list(object({
    name    = string
    enabled = bool
    filters = object({
    prefix_match = list(string)
    blob_types   = list(string)
    })
    actions = object({
    base_blob = object({
        tier_to_cool_after_days_since_modification_greater_than    = number
        tier_to_archive_after_days_since_modification_greater_than = number
        delete_after_days_since_modification_greater_than          = number
    })
    snapshot = object({
        delete_after_days_since_creation_greater_than = number
    })
    })
}))
description = "List of lifecycle management policies for the storage account."
default     = []
}

variable "tags" {
type        = map(string)
description = "Tags to apply to all resources created."
default     = {}
}

variable "environment" {
type        = string
description = "Environment name for the storage account (e.g., dev, test, prod)."
default     = "dev"
}

variable "encryption_scopes" {
type = list(object({
    name                               = string
    enable_infrastructure_encryption   = bool
    source                             = string
    key_vault_key_id                   = string
}))
description = "List of encryption scopes to create."
default     = []
validation {
    condition = alltrue([
    for scope in var.encryption_scopes :
    contains(["Microsoft.Storage", "Microsoft.KeyVault"], scope.source)
    ])
    error_message = "The encryption scope source must be one of 'Microsoft.Storage' or 'Microsoft.KeyVault'."
}
}

variable "expose_access_keys" {
type        = bool
description = "Whether to expose the storage account access keys in the module outputs."
default     = false
}

