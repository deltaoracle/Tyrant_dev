# Azure Infrastructure as Code

This repository contains Terraform configurations for deploying Azure infrastructure components for the Revenue AI project.

## Project Structure

The infrastructure has been organized into logical modules for better maintainability and readability:

### Core Configuration Files

- **`main.tf`** - Overview and documentation of the project structure
- **`providers.tf`** - Terraform configuration and provider blocks (AzureRM, Kubernetes, Helm)
- **`variables.tf`** - Input variables and their default values
- **`output.tf`** - Output values for use by other modules or external systems
- **`backend.tf`** - Terraform backend configuration for state management

### Infrastructure Components

- **`resource-groups.tf`** - Resource group logic and local variables
- **`networking.tf`** - Virtual network, subnets, and DNS zones
- **`container-registry.tf`** - Azure Container Registry (ACR)
- **`kubernetes.tf`** - Azure Kubernetes Service (AKS) cluster, namespaces, and Helm releases
- **`databases.tf`** - PostgreSQL Flexible Server and all databases (dev/test/prod environments)
- **`storage.tf`** - Azure Storage Account resources
- **`key-vault.tf`** - Azure Key Vault and access policies
- **`monitoring.tf`** - Log Analytics Workspace and Application Insights
- **`ai-services.tf`** - Azure OpenAI Service and other AI services
- **`api-management.tf`** - Azure API Management Service for API gateway and management
- **`roles.tf`** - Role assignments and permissions

## Infrastructure Overview

This configuration deploys a complete Azure infrastructure including:

- **Networking**: Virtual network with dedicated subnets for AKS, PostgreSQL, and API Management
- **Container Platform**: AKS cluster with NGINX ingress controller
- **Databases**: PostgreSQL Flexible Server with databases for dev, test, and prod environments
- **Storage**: Azure Storage Account for data persistence
- **Security**: Key Vault for secrets management
- **Monitoring**: Log Analytics and Application Insights for observability
- **AI Services**: Azure OpenAI Service for AI capabilities
- **API Management**: Azure API Management Service for API gateway and management
- **Container Registry**: ACR for container image storage

## Getting Started

1. Ensure you have Terraform installed (version >= 1.0)
2. Configure your Azure credentials
3. Update variables in `variables.tf` as needed
4. Run `terraform init` to initialize the backend
5. Run `terraform plan` to review the deployment plan
6. Run `terraform apply` to deploy the infrastructure

## Terraform Service Principal Requirements

The Terraform service principal used for deploying this infrastructure requires specific Azure AD permissions to successfully create and manage all resources. The following permissions are required:

### Required Azure AD Roles

1. **Contributor Role** (Subscription level)
   - Allows the service principal to create, update, and delete Azure resources
   - Required for managing all infrastructure components (AKS, databases, storage, etc.)

2. **User Administrator Role** (Azure AD level)
   - Allows the service principal to manage users and groups in Azure AD
   - Required for creating and managing service principals, managed identities, and role assignments
   - Enables the service principal to grant permissions to other resources

3. **Application Administrator Role** (Azure AD level)
   - Allows the service principal to manage application registrations and service principals
   - Required for creating and configuring managed identities and application registrations
   - Enables the service principal to manage application permissions and consent

### Setting Up Service Principal Permissions

To configure the required permissions for your Terraform service principal:

```bash
# Get the service principal object ID
SP_OBJECT_ID=$(az ad sp show --id <service-principal-id> --query id -o tsv)

# Assign Contributor role at subscription level
az role assignment create \
  --assignee $SP_OBJECT_ID \
  --role "Contributor" \
  --scope "/subscriptions/<subscription-id>"

# Assign User Administrator role
az ad app permission add \
  --id <service-principal-id> \
  --api 00000000-0000-0000-0000-000000000000 \
  --api-permissions 1cda74f2-2616-4834-b122-5cb1b07fad77=Role

# Assign Application Administrator role
az ad app permission add \
  --id <service-principal-id> \
  --api 00000000-0000-0000-0000-000000000000 \
  --api-permissions 9a5d1b58-3d36-4b81-9082-6aac5538252d=Role

# Grant admin consent
az ad app permission admin-consent --id <service-principal-id>
```

### Alternative: Using Azure CLI for Authentication

If you prefer to use Azure CLI authentication instead of a service principal:

```bash
# Login with Azure CLI
az login

# Set the subscription
az account set --subscription <subscription-id>
```

This approach uses your user account permissions, which should include the necessary roles for infrastructure deployment.

## Backend Setup and Troubleshooting

### Initial Backend Setup

The Terraform configuration uses Azure Storage as the backend for state management. Before running Terraform for the first time, you need to ensure the backend infrastructure exists:

**Resource Group**: `rg-maincluster-all-weu-001`
**Storage Account**: `saixmallweu001`
**Container**: `tfstate`

### Automated Backend Creation

The Azure DevOps pipeline automatically creates the backend infrastructure if it doesn't exist. For manual setup, you can use the provided scripts:

**Windows (PowerShell):**
```powershell
.\create-backend.ps1
```

**Linux/macOS (Bash):**
```bash
./create-backend.sh
```

### Manual Backend Creation

If you prefer to create the backend manually:

```bash
# Create resource group
az group create --name "rg-maincluster-all-weu-001" --location "West Europe"

# Create storage account
az storage account create \
  --name "saixmallweu001" \
  --resource-group "rg-maincluster-all-weu-001" \
  --location "West Europe" \
  --sku "Standard_LRS"

# Create container
az storage container create \
  --name "tfstate" \
  --account-name "saixmallweu001"
```

### Common Issues

**Error: "ResourceGroupNotFound" or "Storage Account not found"**
- This occurs when the backend storage account or resource group doesn't exist
- Solution: Run the backend creation script or create the resources manually
- The pipeline will automatically handle this for CI/CD

**Error: "Failed to get existing workspaces"**
- This happens when Terraform can't access the backend storage
- Ensure the Azure credentials have proper permissions to the storage account
- Verify the subscription ID and resource group name are correct

### Terraform Init with Backend

After the backend infrastructure is created, initialize Terraform with:

```bash
terraform init \
  -backend-config="resource_group_name=rg-maincluster-all-weu-001" \
  -backend-config="storage_account_name=saixmallweu001" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=prod.terraform.tfstate" \
  -backend-config="subscription_id=YOUR_SUBSCRIPTION_ID"
```

## Environment Separation

The infrastructure supports multiple environments through database separation:
- Development databases: `dpnl_ingestion_dev`, `dpnl_ai_dev`, `scheduler_dev`, `dqf_ai_dev`
- Test databases: `dpnl_ingestion_test`, `dpnl_ai_test`, `scheduler_test`, `dqf_ai_test`
- Production databases: `dpnl_ingestion_prod`, `dpnl_ai_prod`, `scheduler_prod`, `dqf_ai_prod`

## Copying Environment to New Subscription

When you need to deploy a copy of the environment to a new Azure subscription, several configuration updates are required:

### Required Updates

1. **Subscription ID**
   - Update the `scope` variable in `variables.tf` with the new subscription ID
   - Update the backend configuration in `backend.tf` with the new subscription ID

2. **Resource Group Names**
   - Update the `resource_group_name_all` variable in `variables.tf`
   - **Shared Resource Group**: `rg-maincluster-all-weu-001` (for AKS, Storage, PostgreSQL, etc.)
   - **Environment-Specific Resource Groups**: When `create_per_env = true`, additional resource groups are created as `{rg_short_name}-{project_name}-{env}-{location}-001` (for Key Vaults, Data Factories)
   - When `create_per_env = false`: Only the shared resource group is used
   - Consider using environment-specific naming (e.g., `rg-maincluster-all-weu-002` for the new subscription)

3. **Storage Account Names**
   - Azure Storage Account names must be globally unique
   - Update the `storage_name` variable in `variables.tf`
   - Example: `saixmallweu002` for the new subscription

4. **Key Vault Configuration**
   - Azure Key Vault names must be globally unique
   - Set `create_per_env = true` to create separate key vaults for each environment (dev, test, prod)
   - Set `create_per_env = false` to create a single key vault using the `key_vault_name` variable
   - When using per-environment: `kv-ixm-dev-weu-001`, `kv-ixm-test-weu-001`, `kv-ixm-prod-weu-001`
   - Naming convention: `{key_vault_short_name}-{project_name}-{env_name}-{short_location}-{unique_number}`
   - When using single key vault: Update the `key_vault_name` variable in `variables.tf`

5. **Data Factory Configuration**
   - Azure Data Factory names must be globally unique
   - Set `create_per_env = true` to create separate data factories for each environment (dev, test, prod)
   - Set `create_per_env = false` to create a single data factory using the `data_factory_name` variable
   - When using per-environment: `adf-ixm-dev-weu-001`, `adf-ixm-test-weu-001`, `adf-ixm-prod-weu-001`
   - Naming convention: `{data_factory_short_name}-{project_name}-{env_name}-{short_location}-{unique_number}`
   - When using single data factory: Update the `data_factory_name` variable in `variables.tf`

6. **Container Registry Names**
   - Azure Container Registry names must be globally unique
   - Update the `acr_name` variable in `variables.tf`
   - Example: `acrixmallweu002`

7. **AKS Cluster Names**
   - Update the `aks_name` variable in `variables.tf`
   - Example: `aks-ixm-all-weu-002`

8. **PostgreSQL Database Names**
   - PostgreSQL Flexible Server names must be globally unique
   - Update the `postgres_name` variable in `variables.tf`
   - Example: `postgres-ixm-all-weu-002`

9. **Application Insights Names**
   - Update the `appinsights_name` variable in `variables.tf`
   - Example: `ai-ixm-all-weu-002`

10. **Log Analytics Workspace Names**
    - Update the `log_analytics_name` variable in `variables.tf`
    - Example: `la-ixm-all-weu-002`

11. **Network Resources**
    - Update the `vnet_name` variable in `variables.tf`
    - Update DNS zone names if using custom domains
    - Example: `vnet-ixm-all-weu-002`

12. **Application Gateway Names**
    - Update the `app_gateway_name` variable in `variables.tf`
    - Example: `appgw-ixm-all-weu-002`

13. **Network Security Group Names**
    - Update the `nsg_name` variable in `variables.tf`
    - Example: `nsg-ixm-all-weu-002`

14. **AKS Managed Resource Group Names**
    - Update the `aks_managed_resource_group_name` variable in `variables.tf`
    - Example: `rg-aks-ixm-all-weu-002`

15. **Azure OpenAI Service Names**
    - Update the `openai_name` variable in `variables.tf`
    - Example: `oai-ixm-all-weu-002`

### Deployment Steps for New Subscription

1. **Create New Backend Infrastructure**
   ```bash
   # Create new resource group for backend
   az group create --name "rg-maincluster-all-weu-002" --location "West Europe"
   
   # Create new storage account
   az storage account create \
     --name "saixmallweu002" \
     --resource-group "rg-maincluster-all-weu-002" \
     --location "West Europe" \
     --sku "Standard_LRS"
   
   # Create container for Terraform state
   az storage container create \
     --name "tfstate" \
     --account-name "saixmallweu002"
   ```

2. **Update Configuration Files**
   - Update all resource names as listed above
   - Update subscription ID in variables and backend configuration
   - Update any environment-specific variables

3. **Initialize Terraform with New Backend**
   ```bash
   terraform init \
     -backend-config="resource_group_name=rg-maincluster-all-weu-002" \
     -backend-config="storage_account_name=saixmallweu002" \
     -backend-config="container_name=tfstate" \
     -backend-config="key=prod.terraform.tfstate" \
     -backend-config="subscription_id=NEW_SUBSCRIPTION_ID"
   ```

4. **Deploy Infrastructure**
   ```bash
   terraform plan
   terraform apply
   ```

### Important Considerations

- **Global Uniqueness**: Many Azure resource names must be globally unique across all Azure subscriptions
- **DNS and Domains**: If using custom domains, ensure DNS zones are properly configured for the new environment
- **Service Principal Permissions**: Ensure the service principal has the required permissions on the new subscription
- **Cost Management**: Monitor costs in the new subscription separately
- **Network Connectivity**: Consider if the new environment needs to connect to existing resources in other subscriptions

## Security Considerations

- PostgreSQL server is deployed with private networking
- Key Vault is configured with appropriate access policies
- AKS uses managed identities for secure access to other Azure resources
- Network security groups and private endpoints are configured where appropriate

## Maintenance

When making changes to the infrastructure:
1. Always review the plan before applying
2. Test changes in a non-production environment first
3. Follow the established naming conventions
4. Update documentation as needed

If you want to learn more about creating good readme files then refer the following [guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops). You can also seek inspiration from the below readme files:
- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
- [Chakra Core](https://github.com/Microsoft/ChakraCore)