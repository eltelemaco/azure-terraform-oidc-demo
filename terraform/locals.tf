# Azure naming convention locals
# Following Microsoft's recommended naming convention: https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming

variable "resource_name_environment" {
  default = ""
}
variable "resource_name_workload" {
  default = ""
}
variable "resource_name_sequence_start" {
  default = ""
}
# locals {
#   # Resource type prefixes
#   resource_type_prefixes = {
#     resource_group         = "rg"
#     app_service_plan       = "plan"
#     app_service            = "app"
#     function_app           = "func"
#     storage_account        = "st"
#     key_vault              = "kv"
#     application_insights   = "appi"
#     service_principal      = "sp"
#     virtual_network        = "vnet"
#     subnet                 = "snet"
#     network_security_group = "nsg"
#     azure_ad_application   = "app"
#   }
#
#   # Region abbreviations
#   region_short_names = {
#     eastus         = "eus"
#     eastus2        = "eus2"
#     centralus      = "cus"
#     westus         = "wus"
#     westus2        = "wus2"
#     northcentralus = "ncus"
#     southcentralus = "scus"
#   }
#
#   # Get the short name for the current region
#   #location_short = lookup(local.region_short_names, var.location, "eus")
#
#   # Standard resource name pattern
#   # Format: <prefix>-<environment>-<region>-<name>-<instance>
#   # Example: rg-dev-eus-oidc-001
#   #resource_name_prefix = "${var.environment}-${local.location_short}"

locals {
  resource_group_name = var.resource_group_create ? module.azurerm_resource_group[0].name : var.resource_group_name
}



