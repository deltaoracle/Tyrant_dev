data "azurerm_storage_account" "existing_storage_account" {
  count               = try(data.azurerm_resource_group.existing_rg_all.id, null) != null ? 1 : 0
  name                = var.storage_name
  resource_group_name = local.resource_group_all_name
}

resource "azurerm_storage_account" "storage" {
  count                    = try(data.azurerm_storage_account.existing_storage_account[0].id, null) == null ? 1 : 0
  name                     = var.storage_name
  resource_group_name      = local.resource_group_all_name
  location                 = local.resource_group_all_location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
} 