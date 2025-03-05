terraform {
  required_version = ">= 1.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.2, < 4.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-terraform-oidc"
    storage_account_name = "storageterraformoidc"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
  provider "azurerm" {
    features {}
}



