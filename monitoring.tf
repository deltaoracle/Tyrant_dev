resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = var.log_analytics_name
  location            = local.resource_group_all_location
  resource_group_name = local.resource_group_all_name
  sku                 = var.log_analytics_sku_name
  retention_in_days   = var.log_analytics_retention_days
}

resource "azurerm_application_insights" "appinsights" {
  name                = var.appinsights_name
  location            = local.resource_group_all_location
  resource_group_name = local.resource_group_all_name
  application_type    = var.application_insights_type
  workspace_id        = azurerm_log_analytics_workspace.log_analytics.id

  depends_on = [azurerm_log_analytics_workspace.log_analytics]
} 