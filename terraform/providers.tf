terraform {
  backend "azurerm" {
    resource_group_name  = local.resource_group_name
    storage_account_name = local.storage_account_name
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0, < 4.0.0"
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

