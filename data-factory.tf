# Create Azure Data Factory for each environment when create_per_env is true
resource "azurerm_data_factory" "adf" {
  for_each                = var.create_per_env ? toset(var.environments) : toset([""])
  name                    = var.create_per_env ? "${var.data_factory_short_name}-${var.project_name}-${each.value}-${var.short_location}-001" : var.data_factory_name
  location                = var.create_per_env ? local.resource_group_per_env[each.value].location : local.resource_group_shared_location
  resource_group_name     = var.create_per_env ? local.resource_group_per_env[each.value].name : local.resource_group_shared_name
  
  # Enable managed virtual network for enhanced security
  managed_virtual_network_enabled = true

  # Enable public network access (can be restricted via NSG)
  public_network_enabled = true

  tags = var.create_per_env ? {
    Environment = each.value
    Project     = var.project_name
  } : {
    Project = var.project_name
  }
}

# Create Data Factory Contributor role assignment for AKS managed identity
resource "azurerm_role_assignment" "aks_adf_contributor" {
  for_each = azurerm_data_factory.adf
  
  scope                = each.value.id
  role_definition_name = "Data Factory Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  principal_type       = "ServicePrincipal"  # Explicitly specify principal type to avoid replication delay issues
}

# Create Data Factory Contributor role assignment for AKS kubelet identity
resource "azurerm_role_assignment" "aks_kubelet_adf_contributor" {
  for_each = azurerm_data_factory.adf
  
  scope                = each.value.id
  role_definition_name = "Data Factory Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  principal_type       = "ServicePrincipal"  # Explicitly specify principal type to avoid replication delay issues
}

# Create Data Factory Contributor role assignment for current service principal
resource "azurerm_role_assignment" "current_service_principal_adf_contributor" {
  for_each = azurerm_data_factory.adf
  
  scope                = each.value.id
  role_definition_name = "Data Factory Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "ServicePrincipal"  # Changed from "User" - actual principal is a service principal
}

# Create Data Factory Contributor role assignment for service principal
# Commented out due to PrincipalNotFound error - service principal doesn't exist
# resource "azurerm_role_assignment" "service_principal_adf_contributor" {
#   for_each = azurerm_data_factory.adf
#   
#   scope                = each.value.id
#   role_definition_name = "Data Factory Contributor"
#   principal_id         = var.client_id
# }
