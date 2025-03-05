terraform {
  backend "azurerm" {
    resource_group_name  = var.azure_resource_group
    storage_account_name = var.azure_storage_account
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

# Azure Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Azure AD Application for OIDC
resource "azuread_application" "az_application" {
  display_name = "GitHub-OIDC-App"
  owners = [data.azuread_client_config.current.object_id]
}

# Get current client configuration from Azure AD
data "azuread_client_config" "current" {}


