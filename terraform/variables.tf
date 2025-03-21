# Azure Authentication Variables
variable "subscription_id" {
  description = "The Subscription ID which should be used"
  type        = string
  sensitive   = true
  default     = ""
}
variable "resource_group_create" {
  type    = bool
  default = false
}
variable "tenant_id" {
  description = "The Tenant ID which should be used"
  type        = string
  sensitive   = true
  default     = ""
}

# Environment and Project Variables
variable "environment" {
  description = "The environment (dev, test, prod, etc.)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "test", "stage", "prod"], var.environment)
    error_message = "The environment must be one of: dev, test, stage, prod."
  }
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "oidc"
}

# Resource Group Variables
variable "resource_group_name" {
  description = "The name of the resource group to create"
  type        = string
  default     = "rg-oidc-demo"
}

variable "storage_account_name" {
  description = "The name of the storage account to create"
  type        = string
  default     = "storageterraformoidc"
}
variable "location" {
  description = "The Azure Region where the resource group should be created"
  type        = string
  default     = "eastus"
}

# Tags Variables
variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default = {
    environment = "demo"
    managed_by  = "terraform"
    source      = "github-actions-oidc"
  }
}

# GitHub OIDC Variables
variable "github_repository" {
  description = "The GitHub repository to grant access to"
  type        = string
  default     = ""
}

# variable "github_branch" {
# description = "The GitHub branch to grant access to"
# type        = string
# default     = "main"
# }


