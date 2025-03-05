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

# # Resource group outputs
# output "azurerm_resource_group" {
#   description = "The name of the Azure resource group"
#   value       = azurerm_resource_group.name
# }
#
# output "resource_group_location" {
#   description = "The location of the Azure resource group"
#   value       = azurerm_resource_group.location
# }
#
# output "github_repository" {
#   description = "The GitHub repository configured for OIDC"
#   value       = var.github_repository
# }

