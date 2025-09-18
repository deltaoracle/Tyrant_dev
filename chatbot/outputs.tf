output "resource_group_name" {
  description = "Name of the chatbot resource group"
  value       = azurerm_resource_group.chatbot_rg.name
}

output "resource_group_id" {
  description = "ID of the chatbot resource group"
  value       = azurerm_resource_group.chatbot_rg.id
}

output "resource_group_location" {
  description = "Location of the chatbot resource group"
  value       = azurerm_resource_group.chatbot_rg.location
}

# Application Insights outputs
output "appinsights_dev_id" {
  description = "ID of the development Application Insights"
  value       = azurerm_application_insights.chatbot_dev.id
}

output "appinsights_dev_instrumentation_key" {
  description = "Instrumentation key for the development Application Insights"
  value       = azurerm_application_insights.chatbot_dev.instrumentation_key
  sensitive   = true
}

output "appinsights_stage_id" {
  description = "ID of the staging Application Insights"
  value       = azurerm_application_insights.chatbot_stage.id
}

output "appinsights_stage_uat_id" {
  description = "ID of the stage uat Application Insights"
  value       = azurerm_application_insights.chatbot_stage_uat.id
}

output "appinsights_stage_instrumentation_key" {
  description = "Instrumentation key for the staging Application Insights"
  value       = azurerm_application_insights.chatbot_stage.instrumentation_key
  sensitive   = true
}

output "appinsights_stage_uat_instrumentation_key" {
  description = "Instrumentation key for the staging Application Insights"
  value       = azurerm_application_insights.chatbot_stage_uat.instrumentation_key
  sensitive   = true
}

output "appinsights_prod_id" {
  description = "ID of the production Application Insights"
  value       = azurerm_application_insights.chatbot_prod.id
}

output "appinsights_prod_instrumentation_key" {
  description = "Instrumentation key for the production Application Insights"
  value       = azurerm_application_insights.chatbot_prod.instrumentation_key
  sensitive   = true
}

# Azure Bot outputs
output "bot_dev_id" {
  description = "ID of the development Azure Bot"
  value       = azurerm_bot_service_azure_bot.chatbot_dev.id
}

output "bot_dev_name" {
  description = "Name of the development Azure Bot"
  value       = azurerm_bot_service_azure_bot.chatbot_dev.name
}

output "bot_stage_id" {
  description = "ID of the staging Azure Bot"
  value       = azurerm_bot_service_azure_bot.chatbot_stage.id
}

output "bot_stage_name" {
  description = "Name of the staging Azure Bot"
  value       = azurerm_bot_service_azure_bot.chatbot_stage.name
}

output "bot_stage_uat_id" {
  description = "ID of the staging Azure Bot"
  value       = azurerm_bot_service_azure_bot.chatbot_stage_uat.id
}

output "bot_stage_uat_name" {
  description = "Name of the staging Azure Bot"
  value       = azurerm_bot_service_azure_bot.chatbot_stage_uat.name
}

output "bot_prod_id" {
  description = "ID of the production Azure Bot"
  value       = azurerm_bot_service_azure_bot.chatbot_prod.id
}

output "bot_prod_name" {
  description = "Name of the production Azure Bot"
  value       = azurerm_bot_service_azure_bot.chatbot_prod.name
}

# Azure AD Application Registration outputs
output "app_registration_dev_id" {
  description = "Application ID of the development bot registration"
  value       = azuread_application.chatbot_dev.application_id
}

output "app_registration_stage_id" {
  description = "Application ID of the staging bot registration"
  value       = azuread_application.chatbot_stage.application_id
}

output "app_registration_stage_uat_id" {
  description = "Application ID of the staging bot registration"
  value       = azuread_application.chatbot_stage_uat.application_id
}

output "app_registration_prod_id" {
  description = "Application ID of the production bot registration"
  value       = azuread_application.chatbot_prod.application_id
} 