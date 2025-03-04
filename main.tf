# Azure Resource Group
resource "azurerm_resource_group" "rg" {
name     = var.resource_group_name
location = var.location
tags     = var.tags
}

# Azure AD Application for OIDC
resource "azuread_application" "github_oidc" {
display_name = "GitHub-OIDC-App"
owners       = [data.azuread_client_config.current.object_id]
}

# Get current client configuration from Azure AD
data "azuread_client_config" "current" {}

# Create service principal for the application
resource "azuread_service_principal" "github_oidc" {
application_id = azuread_application.github_oidc.application_id
}

# Assign Contributor role to the service principal on the resource group
resource "azurerm_role_assignment" "github_oidc_contributor" {
scope                = azurerm_resource_group.rg.id
role_definition_name = "Contributor"
principal_id         = azuread_service_principal.github_oidc.object_id
}

# Create federated identity credential for GitHub Actions OIDC
resource "azuread_application_federated_identity_credential" "github_oidc" {
application_object_id = azuread_application.github_oidc.object_id
display_name          = "github-oidc-credential"
description           = "GitHub Actions OIDC"
audiences             = ["api://AzureADTokenExchange"]
issuer                = "https://token.actions.githubusercontent.com"
subject               = "repo:${var.github_repository}:ref:refs/heads/main"

depends_on = [
    azuread_service_principal.github_oidc
]
}

