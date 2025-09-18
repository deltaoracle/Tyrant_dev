# Chatbot Infrastructure

This folder contains Terraform configurations for Azure Bot Service resources and their associated Application Insights instances.

## Resources Created

### Resource Group
- **Name**: Configurable via `resource_group_name` variable (default: `rg-ixm-chatbot-all-${var.short_location}-001`)
- **Location**: Configurable via `location` variable (default: West Europe)

### Application Insights Resources
All Application Insights instances are connected to the existing Log Analytics workspace:

1. **Development**: Configurable via `appinsights_dev_name` variable (default: `apin-ixm-chatbot-dev-${var.short_location}-001`)
2. **Staging**: Configurable via `appinsights_stage_name` variable (default: `apin-ixm-chatbot-stage-${var.short_location}-001`)
3. **Production**: Configurable via `appinsights_prod_name` variable (default: `apin-ixm-chatbot-prod-${var.short_location}-001`)

### Azure Bot Service Resources
Each bot has its own Azure AD Application Registration and is configured with Global region for optimal availability:

1. **Development**: Configurable via `bot_dev_name` variable (default: `abot-ixm-chatbot-dev-${var.short_location}-001`) (F0 SKU, Global region)
2. **Staging**: Configurable via `bot_stage_name` variable (default: `abot-ixm-chatbot-stage-${var.short_location}-001`) (F0 SKU, Global region)
3. **Production**: Configurable via `bot_prod_name` variable (default: `abot-ixm-chatbot-prod-${var.short_location}-001`) (S1 SKU, Global region)

## Usage

### Prerequisites
- Azure CLI installed and authenticated
- Terraform installed
- Existing Log Analytics workspace in the specified resource group

### Deployment

1. Navigate to the chatbot directory:
   ```bash
   cd chatbot
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the plan:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

### Configuration

You can customize the deployment by creating a `terraform.tfvars` file with your specific values:

```hcl
# Short location code for resource naming
short_location = "weu"

# Basic configuration
location = "West Europe"
resource_group_name = "rg-ixm-chatbot-all-${short_location}-001"

# Shared Resource Group (from main infrastructure)
shared_resource_group_name = "rg-maincluster-all-${short_location}-001"

# Log Analytics workspace details
log_analytics_workspace_name = "la-ixm-all-${short_location}-001"

# Application Insights resource names
appinsights_dev_name = "apin-ixm-chatbot-dev-${short_location}-001"
appinsights_stage_name = "apin-ixm-chatbot-stage-${short_location}-001"
appinsights_prod_name = "apin-ixm-chatbot-prod-${short_location}-001"

# Azure Bot resource names
bot_dev_name = "abot-ixm-chatbot-dev-${short_location}-001"
bot_stage_name = "abot-ixm-chatbot-stage-${short_location}-001"
bot_prod_name = "abot-ixm-chatbot-prod-${short_location}-001"

# Bot endpoint URLs
chatbot_dev_endpoint = "https://your-actual-dev-bot-endpoint.com/api/messages"
chatbot_stage_endpoint = "https://your-actual-stage-bot-endpoint.com/api/messages"
chatbot_prod_endpoint = "https://your-actual-prod-bot-endpoint.com/api/messages"
```

## Important Notes

- All resource names are now configurable through variables for maximum flexibility
- The bot endpoints in the configuration are placeholders. You need to update them with your actual bot endpoints.
- The F0 SKU for dev and stage environments is free tier with limitations.
- The S1 SKU for production provides better performance and features.
- All Application Insights instances are connected to the existing Log Analytics workspace for centralized monitoring.
- Each bot requires its own Azure AD Application Registration for authentication.
- **Bot services are configured with Global region** for optimal availability and to ensure they can be accessed from any Azure region.

## Outputs

After deployment, you can retrieve important information using:

```bash
terraform output
```

Key outputs include:
- Resource group information
- Application Insights IDs and instrumentation keys
- Bot service IDs and names
- Azure AD Application Registration IDs 