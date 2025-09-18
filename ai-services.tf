resource "azurerm_cognitive_account" "openai" {
  name                = var.openai_name
  location            = local.resource_group_all_location
  resource_group_name = local.resource_group_all_name
  kind                = "OpenAI"
  sku_name            = var.openai_sku
} 