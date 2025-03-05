# Get current client configuration from Azure AD
data "azuread_client_config" "current" {}

# Azure Resource Group
module "azurerm_resource_group" {
  source   = "Azure/avm-res-resources-resourcegroup/azurerm"
  version  = "0.2.1"
  location = var.location
  name     = local.resource_group_name
  tags     = var.tags
}
module "virtual_network" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.8.1"

  resource_group_name = local.resource_group_name
  location            = var.location
  name                = local.resource_names["virtual_network_name"]
  subnets             = var.virtual_network_subnets
  address_space       = var.virtual_network_address_space
  tags                = var.tags
}
