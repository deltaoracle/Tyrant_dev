# Short location code for resource naming
short_location = "weu"

# Chatbot Infrastructure Configuration
# This file contains all variables for the chatbot resources

# Azure location for all resources (Note: Bot services are configured as Global)
location = "West Europe"

# Shared Resource Group (from main infrastructure)
shared_resource_group_name = "rg-maincluster-all-weu-001"

# Resource group name for chatbot resources
resource_group_name = "rg-ixm-chatbot-all-weu-001"

# Existing Log Analytics workspace details (references main infrastructure)
log_analytics_workspace_name = "la-ixm-all-weu-001"

# Application Insights resource names
appinsights_dev_name = "apin-ixm-chatbot-dev-weu-001"
appinsights_stage_name = "apin-ixm-chatbot-stage-weu-001"
appinsights_stage_uat_name = "apin-ixm-chatbot-stage-uat-weu-001"
appinsights_prod_name = "apin-ixm-chatbot-prod-weu-001"

# Azure Bot resource names
bot_dev_name = "abot-ixm-chatbot-dev-weu-001"
bot_stage_name = "abot-ixm-chatbot-stage-weu-001"
bot_stage_uat_name = "abot-ixm-chatbot-stage-uat-weu-001"
bot_prod_name = "abot-ixm-chatbot-prod-weu-001"

# Bot endpoint URLs - Update these with your actual bot endpoints
# These should point to your deployed chatbot applications
chatbot_dev_endpoint = "https://your-dev-bot-endpoint.com/api/messages"
chatbot_stage_endpoint = "https://your-stage-bot-endpoint.com/api/messages"
chatbot_stage_uat_endpoint = "https://your-stage-uat-bot-endpoint.com/api/messages"
chatbot_prod_endpoint = "https://your-prod-bot-endpoint.com/api/messages"

# Application Insights Configuration
application_insights_type = "web"

# Azure Bot Configuration
bot_location = "Global"
bot_dev_sku = "F0"
bot_stage_sku = "F0"
bot_stage_uat_sku = "F0"
bot_prod_sku = "S1"

# Project and Environment Tags
project_name = "ixm-chatbot"
environment_dev = "dev"
environment_stage = "stage"
environment_stage_uat = "stage-uat"
environment_prod = "prod"
