terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Data source to get current Azure client configuration (for tenant ID)
data "azurerm_client_config" "current" {}

# Data source to get the existing log analytics workspace
data "azurerm_log_analytics_workspace" "existing" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.shared_resource_group_name
}

# Resource Group for Chatbot resources
resource "azurerm_resource_group" "chatbot_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Application Insights resources
resource "azurerm_application_insights" "chatbot_dev" {
  name                = var.appinsights_dev_name
  location            = azurerm_resource_group.chatbot_rg.location
  resource_group_name = azurerm_resource_group.chatbot_rg.name
  application_type    = var.application_insights_type
  workspace_id        = data.azurerm_log_analytics_workspace.existing.id
}

resource "azurerm_application_insights" "chatbot_stage" {
  name                = var.appinsights_stage_name
  location            = azurerm_resource_group.chatbot_rg.location
  resource_group_name = azurerm_resource_group.chatbot_rg.name
  application_type    = var.application_insights_type
  workspace_id        = data.azurerm_log_analytics_workspace.existing.id
}

resource "azurerm_application_insights" "chatbot_stage_uat" {
  name                = var.appinsights_stage_uat_name
  location            = azurerm_resource_group.chatbot_rg.location
  resource_group_name = azurerm_resource_group.chatbot_rg.name
  application_type    = var.application_insights_type
  workspace_id        = data.azurerm_log_analytics_workspace.existing.id
}

resource "azurerm_application_insights" "chatbot_prod" {
  name                = var.appinsights_prod_name
  location            = azurerm_resource_group.chatbot_rg.location
  resource_group_name = azurerm_resource_group.chatbot_rg.name
  application_type    = var.application_insights_type
  workspace_id        = data.azurerm_log_analytics_workspace.existing.id
}

# Azure Bot resources
resource "azurerm_bot_service_azure_bot" "chatbot_dev" {
  name                = var.bot_dev_name
  resource_group_name = azurerm_resource_group.chatbot_rg.name
  location            = var.bot_location
  microsoft_app_id    = azuread_application.chatbot_dev.application_id #"00574fd5-4db9-44c6-a234-840e7c6e7241" 
  microsoft_app_type  = "SingleTenant"
  microsoft_app_tenant_id = data.azurerm_client_config.current.tenant_id
  sku                 = var.bot_dev_sku

  endpoint = var.chatbot_dev_endpoint

  tags = {
    Environment = var.environment_dev
    Project     = var.project_name
  }
}

resource "azurerm_bot_service_azure_bot" "chatbot_stage" {
  name                = var.bot_stage_name
  resource_group_name = azurerm_resource_group.chatbot_rg.name
  location            = var.bot_location
  microsoft_app_id    = azuread_application.chatbot_stage.application_id
  microsoft_app_type  = "SingleTenant"
  microsoft_app_tenant_id = data.azurerm_client_config.current.tenant_id
  sku                 = var.bot_stage_sku

  endpoint = var.chatbot_stage_endpoint

  tags = {
    Environment = var.environment_stage
    Project     = var.project_name
  }
}

resource "azurerm_bot_service_azure_bot" "chatbot_stage_uat" {
  name                = var.bot_stage_uat_name
  resource_group_name = azurerm_resource_group.chatbot_rg.name
  location            = var.bot_location
  microsoft_app_id    = azuread_application.chatbot_stage_uat.application_id
  microsoft_app_type  = "SingleTenant"
  microsoft_app_tenant_id = data.azurerm_client_config.current.tenant_id
  sku                 = var.bot_stage_uat_sku

  endpoint = var.chatbot_stage_uat_endpoint

  tags = {
    Environment = var.environment_stage_uat
    Project     = var.project_name
  }
}

resource "azurerm_bot_service_azure_bot" "chatbot_prod" {
  name                = var.bot_prod_name
  resource_group_name = azurerm_resource_group.chatbot_rg.name
  location            = var.bot_location
  microsoft_app_id    = azuread_application.chatbot_prod.application_id
  microsoft_app_type  = "SingleTenant"
  microsoft_app_tenant_id = data.azurerm_client_config.current.tenant_id
  sku                 = var.bot_prod_sku

  endpoint = var.chatbot_prod_endpoint

  tags = {
    Environment = var.environment_prod
    Project     = var.project_name
  }
}

# Azure AD Application Registrations for the bots
resource "azuread_application" "chatbot_dev" {
  display_name = var.bot_dev_name
  sign_in_audience = "AzureADMyOrg"  # Single tenant
}

resource "azuread_application" "chatbot_stage" {
  display_name = var.bot_stage_name
  sign_in_audience = "AzureADMyOrg"  # Single tenant
}

resource "azuread_application" "chatbot_stage_uat" {
  display_name = var.bot_stage_uat_name
  sign_in_audience = "AzureADMyOrg"  # Single tenant
}

resource "azuread_application" "chatbot_prod" {
  display_name = var.bot_prod_name
  sign_in_audience = "AzureADMyOrg"  # Single tenant
} 