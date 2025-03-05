# Get current client configuration from Azure AD
data "azuread_client_config" "current" {}

# Azure Resource Group
module "azurerm_resource_group" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.1"
  location = var.location
  name     = var.resource_group_name
  tags     = var.tags
}