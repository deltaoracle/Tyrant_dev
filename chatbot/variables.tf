# Short location variable for consistent naming across resources
variable "short_location" {
  description = "Short location code for resource naming (e.g., 'weu' for West Europe)"
  type        = string
  default     = "weu"
}

variable "location" {
  description = "Azure location for chatbot resources"
  type        = string
  default     = "West Europe"
}

# Shared Resource Group (from main infrastructure)
variable "shared_resource_group_name" {
  description = "Name of the shared resource group from main infrastructure"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name for chatbot resources"
  type        = string
  default     = "rg-ixm-chatbot-all-weu-001"
}

variable "log_analytics_workspace_name" {
  description = "Name of the existing Log Analytics workspace"
  type        = string
  default     = "la-ixm-all-weu-001"
}

# Application Insights resource names
variable "appinsights_dev_name" {
  description = "Name of the development Application Insights"
  type        = string
  default     = "apin-ixm-chatbot-dev-weu-001"
}

variable "appinsights_stage_name" {
  description = "Name of the staging Application Insights"
  type        = string
  default     = "apin-ixm-chatbot-stage-weu-001"
}

variable "appinsights_stage_uat_name" {
  description = "Name of the staging Application Insights"
  type        = string
  default     = "apin-ixm-chatbot-stage-uat-weu-001"
}

variable "appinsights_prod_name" {
  description = "Name of the production Application Insights"
  type        = string
  default     = "apin-ixm-chatbot-prod-weu-001"
}

# Azure Bot resource names
variable "bot_dev_name" {
  description = "Name of the development Azure Bot"
  type        = string
  default     = "abot-ixm-chatbot-dev-weu-001"
}

variable "bot_stage_name" {
  description = "Name of the staging Azure Bot"
  type        = string
  default     = "abot-ixm-chatbot-stage-weu-001"
}

variable "bot_stage_uat_name" {
  description = "Name of the staging Azure Bot"
  type        = string
  default     = "abot-ixm-chatbot-stage-uat-weu-001"
}

variable "bot_prod_name" {
  description = "Name of the production Azure Bot"
  type        = string
  default     = "abot-ixm-chatbot-prod-weu-001"
}

# Bot endpoint URLs
variable "chatbot_dev_endpoint" {
  description = "Endpoint URL for the development chatbot"
  type        = string
  default     = "https://your-dev-bot-endpoint.com/api/messages"
}

variable "chatbot_stage_endpoint" {
  description = "Endpoint URL for the staging chatbot"
  type        = string
  default     = "https://your-stage-bot-endpoint.com/api/messages"
}

variable "chatbot_stage_uat_endpoint" {
  description = "Endpoint URL for the staging chatbot"
  type        = string
  default     = "https://your-stage-uat-bot-endpoint.com/api/messages"
}

variable "chatbot_prod_endpoint" {
  description = "Endpoint URL for the production chatbot"
  type        = string
  default     = "https://your-prod-bot-endpoint.com/api/messages"
}

# Application Insights Configuration
variable "application_insights_type" {
  description = "Application Insights type for chatbot resources"
  type        = string
  default     = "web"
}

# Azure Bot Configuration
variable "bot_location" {
  description = "Azure Bot Service location (must be Global)"
  type        = string
  default     = "Global"
}

variable "bot_dev_sku" {
  description = "Azure Bot Service SKU for development environment"
  type        = string
  default     = "F0"
}

variable "bot_stage_sku" {
  description = "Azure Bot Service SKU for staging environment"
  type        = string
  default     = "F0"
}

variable "bot_stage_uat_sku" {
  description = "Azure Bot Service SKU for stage uat environment"
  type        = string
  default     = "F0"
}


variable "bot_prod_sku" {
  description = "Azure Bot Service SKU for production environment"
  type        = string
  default     = "S1"
}

# Project and Environment Tags
variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "ixm-chatbot"
}

variable "environment_dev" {
  description = "Environment name for development resources"
  type        = string
  default     = "dev"
}

variable "environment_stage" {
  description = "Environment name for staging resources"
  type        = string
  default     = "stage"
}

variable "environment_stage_uat" {
  description = "Environment name for staging resources"
  type        = string
  default     = "stage_uat"
}

variable "environment_prod" {
  description = "Environment name for production resources"
  type        = string
  default     = "prod"
} 