data "azurerm_resource_group" "existing_rg_all" {
  name = var.resource_group_name_all
}

# Create resource groups based on environment configuration
resource "azurerm_resource_group" "rg_per_env" {
  for_each = var.create_per_env ? toset(var.environments) : toset([])
  
  name     = "${var.rg_short_name}-${var.project_name}-${each.value}-${var.short_location}-001"
  location = var.location

  tags = {
    Environment = each.value
    Project     = var.project_name
  }
}

# Create shared resource group for all environments
resource "azurerm_resource_group" "rg_shared" {
  count    = var.create_per_env ? 0 : 1
  
  name     = var.resource_group_name_all
  location = var.location

  tags = {
    Environment = var.environment_name
    Project     = var.project_name
  }
}

# Keep existing shared resource group for common resources (AKS, Storage, etc.)
resource "azurerm_resource_group" "rg" {
  count    = length(data.azurerm_resource_group.existing_rg_all) == 0 ? 1 : 0
  
  name     = var.resource_group_name_all
  location = var.location

  tags = {
    Environment = var.environment_name
    Project     = var.project_name
  }
}

# Local variables for resource group references
locals {
  # Resource group for per-environment resources (Key Vaults, Data Factories)
  resource_group_per_env = var.create_per_env ? {
    for env, rg in azurerm_resource_group.rg_per_env : env => {
      name     = rg.name
      location = rg.location
      id       = rg.id
    }
  } : {}

  # Resource group for shared resources (AKS, Storage, etc.)
  resource_group_shared = var.create_per_env ? azurerm_resource_group.rg_per_env[var.environments[0]] : azurerm_resource_group.rg_shared[0]

  # Resource group name for shared resources
  resource_group_shared_name = var.create_per_env ? azurerm_resource_group.rg_per_env[var.environments[0]].name : azurerm_resource_group.rg_shared[0].name

  # Resource group location for shared resources
  resource_group_shared_location = var.create_per_env ? azurerm_resource_group.rg_per_env[var.environments[0]].location : azurerm_resource_group.rg_shared[0].location

  # Keep existing local variables for backward compatibility
  resource_group_all_name     = length(data.azurerm_resource_group.existing_rg_all) > 0 ? data.azurerm_resource_group.existing_rg_all.name : azurerm_resource_group.rg[0].name
  resource_group_all_location = length(data.azurerm_resource_group.existing_rg_all) > 0 ? data.azurerm_resource_group.existing_rg_all.location : azurerm_resource_group.rg[0].location
  resource_group_all_id       = length(data.azurerm_resource_group.existing_rg_all) > 0 ? data.azurerm_resource_group.existing_rg_all.id : azurerm_resource_group.rg[0].id
} 