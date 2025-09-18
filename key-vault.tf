# Create Azure AD group for Key Vault access
# resource "azuread_group" "kv_access_group" {
#   display_name     = var.kv_access_group
#   description      = "Group for Key Vault access permissions"
#   security_enabled = true
# }

# Create Key Vault for each environment when create_per_env is true
resource "azurerm_key_vault" "kv" {
  for_each                    = var.create_per_env ? toset(var.environments) : toset([""])
  name                        = var.create_per_env ? "${var.key_vault_short_name}-${var.project_name}-${each.value}-${var.short_location}-001" : var.key_vault_name
  location                    = var.create_per_env ? local.resource_group_per_env[each.value].location : local.resource_group_shared_location
  resource_group_name         = var.create_per_env ? local.resource_group_per_env[each.value].name : local.resource_group_shared_name
  enabled_for_disk_encryption = var.key_vault_enabled_for_disk_encryption
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = var.key_vault_soft_delete_retention_days
  purge_protection_enabled    = var.key_vault_purge_protection_enabled

  sku_name = var.key_vault_sku

  network_acls {
    default_action = var.key_vault_network_default_action
    bypass         = var.key_vault_network_bypass
  }

  tags = var.create_per_env ? {
    Environment = each.value
    Project     = var.project_name
  } : {
    Project = var.project_name
  }
}

# Grant AKS managed identity access to all Key Vaults
# Consolidated policy using kubelet identity (recommended approach)
resource "azurerm_key_vault_access_policy" "aks_kv_access" {
  for_each      = azurerm_key_vault.kv
  key_vault_id  = each.value.id
  tenant_id     = data.azurerm_client_config.current.tenant_id
  object_id     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

  key_permissions = [
    "Get",
    "List",
    "Create",
    "Delete",
    "Update",
    "Import",
    "Backup",
    "Restore",
    "Recover"
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Backup",
    "Restore",
    "Recover"
  ]

  certificate_permissions = [
    "Get",
    "List",
    "Create",
    "Delete",
    "Update",
    "Import",
    "Backup",
    "Restore",
    "Recover",
    "ManageContacts",
    "ManageIssuers",
    "GetIssuers",
    "ListIssuers",
    "SetIssuers",
    "DeleteIssuers"
  ]

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# REMOVED: Duplicate AKS kubelet access policy - consolidated above
# The kubelet identity is the recommended approach for AKS Key Vault access

# Grant current user access to all Key Vaults for Terraform operations
resource "azurerm_key_vault_access_policy" "current_user_kv_access" {
  for_each      = azurerm_key_vault.kv
  key_vault_id  = each.value.id
  tenant_id     = data.azurerm_client_config.current.tenant_id
  object_id     = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get",
    "List",
    "Create",
    "Delete",
    "Update",
    "Import",
    "Backup",
    "Restore",
    "Recover"
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Backup",
    "Restore",
    "Recover"
  ]

  certificate_permissions = [
    "Get",
    "List",
    "Create",
    "Delete",
    "Update",
    "Import",
    "Backup",
    "Restore",
    "Recover",
    "ManageContacts",
    "ManageIssuers",
    "GetIssuers",
    "ListIssuers",
    "SetIssuers",
    "DeleteIssuers"
  ]
}

# Certificate file operations have been moved to the certificates/ module
# The following resources are now managed by the certificates module:
# - azurerm_key_vault_certificate.wildcard_cert
# - azurerm_key_vault_secret.wildcard_cert_chain  
# - azurerm_key_vault_secret.wildcard_private_key
# 
# AKS access policies remain here for better organization and dependency management

# Key Vault access policy for the group
# resource "azurerm_key_vault_access_policy" "kv_access_policy" {
#   key_vault_id = azurerm_key_vault.kv.id
#   tenant_id    = data.azurerm_client_config.current.tenant_id
#   object_id    = azuread_group.kv_access_group.object_id
#
#   key_permissions = [
#     "Get",
#     "List",
#     "Create",
#     "Delete",
#     "Update",
#     "Import",
#     "Backup",
#     "Restore",
#     "Recover"
#   ]
#
#   secret_permissions = [
#     "Get",
#     "List",
#     "Set",
#     "Delete",
#     "Backup",
#     "Restore",
#     "Recover"
#   ]
#
#   certificate_permissions = [
#     "Get",
#     "List",
#     "Create",
#     "Delete",
#     "Update",
#     "Import",
#     "Backup",
#     "Restore",
#     "Recover"
#   ]
#
#   storage_permissions = [
#     "Get",
#     "List",
#     "Set",
#     "Delete",
#     "Backup",
#     "Restore",
#     "Recover"
#   ]
# }

data "azurerm_client_config" "current" {} 