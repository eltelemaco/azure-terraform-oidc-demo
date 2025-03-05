terraform {
  backend "azurerm" {}
  required_version = ">= 1.1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.2, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  # OIDC Authentication configuration
  use_oidc        = true
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

resource "azurerm_resource_group" "rg_name" {
  name = var.resource_group_name
  location = var.location
}

