# Azure Terraform OIDC Demo

This repository demonstrates how to deploy Azure resources using Terraform and GitHub Actions with OpenID Connect (OIDC)
authentication. OIDC provides a more secure way to authenticate with Azure without storing long-lived credentials in
GitHub secrets.

## Overview

This project sets up:

- Azure Active Directory application and service principal
- OIDC federation between GitHub Actions and Azure
- Terraform configuration to deploy an Azure resource group
- GitHub Actions workflow for automated deployment

## Prerequisites
 
- Azure subscription 
- GitHub account
- Azure CLI installed locally
- Terraform CLI installed locally
- Owner or Contributor permissions on your Azure subscription
- Permissions to create applications in Azure Active Directory

## Azure Configuration

### 1. Sign in to Azure

```bash
az login
```

### 2. Set the active subscription

```bash
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### 3. Create a service principal with the Contributor role

```bash
az ad sp create-for-rbac --name "github-actions-oidc-sp" --role contributor --scopes /subscriptions/YOUR_SUBSCRIPTION_ID --json-auth
```

Save the output JSON - you'll need these values later:

- `clientId`
- `clientSecret`
- `tenantId`
- `subscriptionId`

### 4. Create an App Registration for OIDC

```bash
APP_NAME="github-actions-oidc"

# Create the application
appId=$(az ad app create --display-name $APP_NAME --query appId -o tsv)

# Create a service principal for the application
spId=$(az ad sp create --id $appId --query id -o tsv)

# Assign Contributor role to the service principal
az role assignment create --assignee $appId --role Contributor --scope /subscriptions/YOUR_SUBSCRIPTION_ID
```

### 5. Configure OIDC federation for GitHub

```bash
# Set your GitHub repo details
GITHUB_REPO="your-username/azure-terraform-oidc-demo"

# Add the federated credential
az ad app federated-credential create --id $appId --parameters "{\"name\":\"github-actions-oidc\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${GITHUB_REPO}:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"
```

## GitHub Repository Setup

### 1. Fork or clone this repository

```bash
git clone https://github.com/your-username/azure-terraform-oidc-demo.git
cd azure-terraform-oidc-demo
```

### 2. Configure GitHub repository secrets and variables

Navigate to your GitHub repository → Settings → Secrets and variables → Actions

Add the following repository secrets:

- None required! (That's the benefit of OIDC)

Add the following repository variables:

- `AZURE_CLIENT_ID`: The Client ID of your App Registration
- `AZURE_TENANT_ID`: Your Azure tenant ID
- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID
- `GITHUB_REPOSITORY`: Your GitHub repository name (e.g., "your-username/azure-terraform-oidc-demo")

## Running the Workflow

1. Push changes to your repository's main branch to trigger the workflow automatically
2. Alternatively, manually trigger the workflow:

- Go to the "Actions" tab in your GitHub repository
- Select the "Terraform Deploy" workflow
- Click "Run workflow" and select the branch to run from

The workflow will:

1. Authenticate to Azure using OIDC
2. Initialize Terraform
3. Create a Terraform plan
4. Apply the changes if approved

## Workflow Configuration

The GitHub Actions workflow is defined in `.github/workflows/terraform-deploy.yml`. This workflow:

- Runs on pushes to the main branch or can be manually triggered
- Uses OIDC to authenticate with Azure
- Sets up Terraform with remote state storage in Azure
- Performs Terraform init, plan, and apply operations

## Project Structure

```
azure-terraform-oidc-demo/
├── .github/
│   └── workflows/
│       └── terraform-deploy.yml  # GitHub Actions workflow file
├── main.tf                       # Main Terraform configuration
├── variables.tf                  # Terraform variables definition
├── outputs.tf                    # Terraform outputs
├── providers.tf                  # Provider configuration with OIDC setup
└── README.md                     # This file
```

## Customizing the Deployment

To deploy additional Azure resources, modify the `main.tf` file to include your desired resources. Remember to update
the `variables.tf` file if you need additional variables.

## Troubleshooting

### Common Issues

1. **Authentication Failure**: Ensure your App Registration has the correct permissions and the federated credential is
   configured properly.

2. **Missing Variables**: Check that all required GitHub variables are set correctly.

3. **Repository Name Format**: Ensure the GITHUB_REPOSITORY variable uses the format "username/repository".

4. **Workflow Permissions**: Make sure your workflow has the `id-token: write` permission set.

### Debugging Tips

- Check the GitHub Actions logs for detailed error messages
- Verify Azure permissions using the Azure portal
- Test the authentication locally using the Azure CLI

## Security Considerations

- OIDC eliminates the need to store long-lived credentials in GitHub secrets
- The federation is scoped to a specific GitHub repository and branch
- Always follow the principle of least privilege when assigning roles

## License

This project is licensed under the MIT License - see the LICENSE file for details.

