# Output the Azure subscription details needed for OIDC authentication
output "azure_subscription_id" {
  description = "The Azure Subscription ID"
  value       = var.subscription_id
  sensitive   = true
}

output "azure_tenant_id" {
  description = "The Azure Tenant ID"
  value       = var.tenant_id
  sensitive   = true
}

output "azure_client_id" {
  description = "The Azure Client ID (Application ID) for OIDC authentication"
  value       = azuread_application.az_application.client_id
  sensitive   = true
}

# Resource group outputs
output "resource_group_name" {
  description = "The name of the Azure resource group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "The location of the Azure resource group"
  value       = azurerm_resource_group.rg.location
}

# GitHub OIDC configuration outputs
output "github_oidc_application_name" {
  description = "The name of the Azure AD application for GitHub OIDC"
  value       = azuread_application.az_application.display_name
}

output "github_repository" {
  description = "The GitHub repository configured for OIDC"
  value       = var.github_repository
}

