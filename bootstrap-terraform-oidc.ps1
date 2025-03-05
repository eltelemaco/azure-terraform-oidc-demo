<#
.SYNOPSIS
Sets up Azure resources for Terraform with OIDC authentication via GitHub Actions

.DESCRIPTION
This script creates the necessary Azure resources for using Terraform with OIDC authentication:
- Resource group for Terraform-managed resources
- Azure AD application with federated credentials for GitHub Actions
- Storage account and container for Terraform state
- Proper RBAC role assignments

.PARAMETER SubscriptionId
The Azure Subscription ID where resources will be created

.PARAMETER ResourceGroupName
The name of the resource group to create for Terraform resources

.PARAMETER Location
The Azure region where resources will be created

.PARAMETER AppName
The name of the Azure AD application to create

.PARAMETER StorageAccountName
The name of the storage account to create for Terraform state

.PARAMETER GithubOrg
The GitHub organization/username that will be authorized for OIDC

.PARAMETER GithubRepo
The GitHub repository that will be authorized for OIDC

.PARAMETER GithubBranch
The GitHub branch that will be authorized for OIDC

.EXAMPLE
.\bootstrap-azure-oidc.ps1 -SubscriptionId "00000000-0000-0000-0000-000000000000" -ResourceGroupName "rg-terraform-oidc" -GithubOrg "myorg" -GithubRepo "myrepo"

.NOTES
Version:        1.0
Author:         Azure Terraform OIDC Demo
Creation Date:  2023-05-15
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [string]$Location = "eastus",

    [Parameter(Mandatory = $false)]
    [string]$AppName = "az-terraform-oidc-app",

    [Parameter(Mandatory = $false)]
    [string]$StorageAccountName = "storageterraformoidc",

    [Parameter(Mandatory = $true)]
    [string]$GithubOrg,

    [Parameter(Mandatory = $true)]
    [string]$GithubRepo,

    [Parameter(Mandatory = $false)]
    [string]$GithubBranch = "main"
)

# Functions
function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO", "WARN", "ERROR")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

function Test-AzModules {
    if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
        Write-Log "Az PowerShell modules are not installed. Installing..." "WARN"
        Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
    }
}

# Main script execution
try {
    # Check for required PowerShell modules
    Test-AzModules

    # Generate storage account name if not provided
    if (-not $StorageAccountName) {
        $random = -join ((48..57) + (97..122) | Get-Random -Count 8 | ForEach-Object { [char]$_ })
        $StorageAccountName = "tfstate$random"
    }

    # Connect to Azure
    Write-Log "Connecting to Azure subscription $SubscriptionId..."
    Connect-AzAccount -Subscription $SubscriptionId
    $context = Get-AzContext
    $tenantId = $context.Tenant.Id
    Write-Log "Connected to Azure subscription $SubscriptionId in tenant $tenantId"

    # Create Resource Group if it doesn't exist
    Write-Log "Checking for resource group $ResourceGroupName..."
    $resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $resourceGroup) {
        Write-Log "Resource group $ResourceGroupName doesn't exist, creating in $Location..."
        $resourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
        Write-Log "Resource group created successfully."
    }
    else {
        Write-Log "Resource group $ResourceGroupName already exists." "WARN"
    }

    # Create Azure AD Application
    Write-Log "Checking if Azure AD application $AppName exists..."
    $app = Get-AzADApplication -DisplayName $AppName -ErrorAction SilentlyContinue
    if (-not $app) {
        Write-Log "Azure AD application $AppName doesn't exist, creating..."
        $app = New-AzADApplication -DisplayName $AppName
        Write-Log "Azure AD application created with ID: $($app.AppId)"
    } else {
        Write-Log "Azure AD application $AppName already exists with ID: $($app.AppId)"
    }
    $appId = $app.AppId

    # Create Service Principal for the application
    Write-Log "Creating Service Principal for application..."
    $sp = Get-AzADServicePrincipal -ApplicationId $appId -ErrorAction SilentlyContinue
    if (-not $sp) {
        Write-Log "Service Principal doesn't exist, creating..."
        $sp = New-AzADServicePrincipal -ApplicationId $appId
        Write-Log "Service Principal created with ID: $($sp.Id)"
    } else {
        Write-Log "Service Principal already exists with ID: $($sp.Id)"
    }

    # Set up federated credentials for GitHub Actions
    Write-Log "Setting up federated credentials for GitHub Actions..."
    $issuer = "https://token.actions.githubusercontent.com"
    $subject = "repo`:$GithubOrg/$GithubRepo`:`ref`:`refs/heads/$GithubBranch"
    $fedCredParams = @{
        ApplicationObjectId = $app.Id
        Audience            = "api://AzureADTokenExchange"
        Issuer              = $issuer
        Name                = "github-actions-oidc"
        Subject             = $subject
    }
    $fedCred = New-AzADAppFederatedCredential @fedCredParams
    Write-Log "Federated credentials configured: $($fedCred.Name)"

    # Create Storage Account for Terraform state
    Write-Log "Creating Storage Account $StorageAccountName..."
    # Register the Microsoft.Storage resource provider
    Register-AzResourceProvider -ProviderNamespace Microsoft.Storage
    $storageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue
    if (-not $storageAccount) {
        Write-Log "Storage Account $StorageAccountName doesn't exist, creating..."
        $storageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupName `
            -Name $StorageAccountName `
            -Location $Location `
            -SkuName "Standard_LRS" `
            -Kind "StorageV2" `
            -EnableHttpsTrafficOnly $true `
            -MinimumTlsVersion "TLS1_2" `
            -AllowBlobPublicAccess $false
        Write-Log "Storage Account created successfully $storageAccount."
    } else {
        Write-Log "Storage Account $StorageAccountName already exists."
    }

    # Create a container in the storage account
    Write-Log "Creating container for Terraform state..."
    $container = Get-AzStorageContainer -Name "tfstate" -Context $storageAccount.Context -ErrorAction SilentlyContinue
    if (-not  $container) {
        $ctx = $storageAccount.Context
        $container = New-AzStorageContainer -Name "tfstate" -Context $ctx
        Write-Log "Container created successfully $container."
    } else {
        Write-Log "Failed to get storage account context." "ERROR"
    }

    # Assign Contributor role to the Service Principal at subscription scope
    Write-Log "Assigning Contributor role to the Service Principal..."
    New-AzRoleAssignment -ApplicationId $appId -RoleDefinitionName "Contributor" -Scope "/subscriptions/$SubscriptionId"
    Write-Log "Role assigned successfully."

    # Assign Storage Blob Data Contributor role to the Service Principal for the storage account
    Write-Log "Assigning Storage Blob Data Contributor role to the Service Principal..."
    $storageAccountId = $storageAccount.Id
    $roleAssignment = Get-AzRoleAssignment -ObjectId $sp.Id -RoleDefinitionName "Storage Blob Data Contributor" -Scope $storageAccountId -ErrorAction SilentlyContinue
    if (-not $roleAssignment) {
        New-AzRoleAssignment -ApplicationId $appId -RoleDefinitionName "Storage Blob Data Contributor" -Scope $storageAccountId
        Write-Log "Role assigned successfully."
    } else {
        Write-Log "Role assignment already exists."  "WARN"
    }

    # Output results
    Write-Log "Azure resources for Terraform with OIDC authentication have been successfully created." "INFO"
    Write-Log "================ Configuration Information ================" "INFO"
    Write-Log "AZURE_CLIENT_ID: $appId" "INFO"
    Write-Log "AZURE_TENANT_ID: $tenantId" "INFO"
    Write-Log "AZURE_SUBSCRIPTION_ID: $SubscriptionId" "INFO"
    Write-Log "AZURE_RESOURCE_GROUP: $ResourceGroupName" "INFO"
    Write-Log "STORAGE_ACCOUNT_NAME: $StorageAccountName" "INFO"
    Write-Log "CONTAINER_NAME: tfstate" "INFO"
    Write-Log "=========================================================" "INFO"
    Write-Log "Add these as GitHub repository secrets/variables for use with GitHub Actions." "INFO"
    Write-Log "For backends.tf, use the following configuration:" "INFO"
    Write-Log "terraform backend \"azurerm\" {
    resource_group_name  = \"$ResourceGroupName\"
    storage_account_name = \"$StorageAccountName\"
    container_name       = \"tfstate\"
    key                  = \"terraform.tfstate\"}" "INFO"}
catch {
    Write-Log "An error occurred: $_" "ERROR"
    Write-Log $_.ScriptStackTrace "ERROR"
}