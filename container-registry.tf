resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = local.resource_group_all_name
  location            = local.resource_group_all_location
  sku                 = var.acr_sku
  admin_enabled       = true
} 