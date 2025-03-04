# Azure naming convention locals
# Following Microsoft's recommended naming convention: https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming

locals {
# Resource type prefixes
resource_type_prefixes = {
    resource_group                 = "rg"
    app_service_plan               = "plan"
    app_service                    = "app"
    function_app                   = "func"
    storage_account                = "st"
    key_vault                      = "kv"
    application_insights           = "appi"
    service_principal              = "sp"
    virtual_network                = "vnet"
    subnet                         = "snet"
    network_security_group         = "nsg"
    azure_ad_application           = "app"
}

# Region abbreviations
region_short_names = {
    eastus             = "eus"
    eastus2            = "eus2"
    centralus          = "cus"
    westus             = "wus"
    westus2            = "wus2"
    westeurope         = "weu"
    northeurope        = "neu"
    southeastasia      = "sea"
    eastasia           = "ea"
    japaneast          = "jpe"
    japanwest          = "jpw"
    australiaeast      = "aue"
    australiasoutheast = "ause"
    southindia         = "sin"
    centralindia       = "cin"
    westindia          = "win"
    canadacentral      = "cac"
    canadaeast         = "cae"
    uksouth            = "uks"
    ukwest             = "ukw"
    francecentral      = "frc"
    northcentralus     = "ncus"
    southcentralus     = "scus"
}

# Get the short name for the current region
location_short = lookup(local.region_short_names, var.location, "uks")

# Standard resource name pattern
# Format: <prefix>-<environment>-<region>-<name>-<instance>
# Example: rg-dev-eus-oidc-001
resource_name_prefix = "${var.environment}-${local.location_short}"

# Resource-specific name generators
resource_group_name = lower(
    "${local.resource_type_prefixes.resource_group}-${local.resource_name_prefix}-${var.project_name}"
)

# OIDC application name
application_name = lower(
    "${local.resource_type_prefixes.azure_ad_application}-${local.resource_name_prefix}-${var.project_name}-oidc"
)

# Common tags applied to all resources
common_tags = merge(var.tags, {
    environment = var.environment
    project     = var.project_name
})
}

