locals {
  storage_account_name = try(data.azurerm_storage_account.existing_storage_account[0].name, null) != null ? data.azurerm_storage_account.existing_storage_account[0].name : azurerm_storage_account.storage[0].name
}

output "aks_cluster_name" {
  description = "AKS cluster Name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_cluster_endpoint" {
  description = "AKS cluster API endpoint"
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.host
  sensitive   = true
}

output "storage_account_name" {
  description = "Storage account name"
  value       = local.storage_account_name
}

output "vnet_name" {
  description = "Virtual Network name"
  value       = azurerm_virtual_network.vnet.name
}

output "aks_subnet_id" {
  description = "AKS subnet ID"
  value       = azurerm_subnet.aks_subnet_new.id
}

output "aks_nsg_id" {
  description = "AKS Network Security Group ID"
  value       = azurerm_network_security_group.aks_nsg.id
}

output "aks_nsg_name" {
  description = "AKS Network Security Group Name"
  value       = azurerm_network_security_group.aks_nsg.name
}

output "aks_managed_resource_group_name" {
  description = "AKS Managed Resource Group Name"
  value       = var.aks_managed_resource_group_name
}

output "postgres_subnet_id" {
  description = "PostgreSQL subnet ID"
  value       = azurerm_subnet.postgres_subnet.id
}

# Application Gateway outputs
output "app_gateway_name" {
  description = "Application Gateway name"
  value       = azurerm_application_gateway.appgw.name
}

output "app_gateway_public_ip" {
  description = "Application Gateway Public IP Address"
  value       = azurerm_public_ip.appgw.ip_address
}

output "app_gateway_frontend_ip_configuration" {
  description = "Application Gateway Frontend IP Configuration"
  value       = azurerm_application_gateway.appgw.frontend_ip_configuration[0].name
}

output "app_gateway_subnet_id" {
  description = "Application Gateway subnet ID"
  value       = azurerm_subnet.app_gateway_subnet.id
}

output "app_gateway_nsg_id" {
  description = "Application Gateway Network Security Group ID"
  value       = azurerm_network_security_group.appgw_nsg.id
}

output "nginx_ingress_loadbalancer_ip" {
  description = "NGINX Ingress Controller LoadBalancer IP"
  value       = "172.212.25.116"
}

# ACR outputs
output "acr_name" {
  description = "Azure Container Registry name"
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "Azure Container Registry login server"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "Azure Container Registry admin username"
  value       = azurerm_container_registry.acr.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "Azure Container Registry admin password"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

output "acr_pull_secret_name" {
  description = "Kubernetes ACR pull secret name"
  value       = "acr-pull-secret"
}

output "acr_pull_secret_namespaces" {
  description = "Namespaces where ACR pull secret is created"
  value       = ["dev", "test", "stage","stage-uat", "prod"]
}

# Public PostgreSQL Database outputs
output "postgres_public_server_name" {
  description = "Public PostgreSQL Flexible Server name"
  value       = azurerm_postgresql_flexible_server.postgres_public.name
}

output "postgres_public_server_fqdn" {
  description = "Public PostgreSQL Flexible Server FQDN"
  value       = azurerm_postgresql_flexible_server.postgres_public.fqdn
}

output "postgres_public_connection_string" {
  description = "Public PostgreSQL connection string"
  value       = "postgresql://${var.postgres_administrator_login}:${var.postgres_administrator_password}@${azurerm_postgresql_flexible_server.postgres_public.fqdn}:5432/dpnl_ingestion_prod"
  sensitive   = true
}

output "postgres_private_endpoint" {
  description = "PostgreSQL Private Endpoint (for VNet integration)"
  value       = "${azurerm_postgresql_flexible_server.postgres_public.name}.privatelink.postgres.database.azure.com"
}

output "postgres_private_endpoint_ip" {
  description = "PostgreSQL Private Endpoint IP Address"
  value       = azurerm_private_endpoint.postgres_public.private_service_connection[0].private_ip_address
}

# Key Vault outputs for each environment
output "key_vaults" {
  description = "Key Vault details for each environment or single key vault"
  value = var.create_per_env ? {
    for env, kv in azurerm_key_vault.kv : env => {
      name = kv.name
      id   = kv.id
      uri  = kv.vault_uri
    }
  } : {
    "single" = {
      name = azurerm_key_vault.kv[""].name
      id   = azurerm_key_vault.kv[""].id
      uri  = azurerm_key_vault.kv[""].vault_uri
    }
  }
}

output "key_vault_names" {
  description = "Key Vault names for each environment or single key vault"
  value = var.create_per_env ? {
    for env, kv in azurerm_key_vault.kv : env => kv.name
  } : {
    "single" = azurerm_key_vault.kv[""].name
  }
}

output "key_vault_uris" {
  description = "Key Vault URIs for each environment or single key vault"
  value = var.create_per_env ? {
    for env, kv in azurerm_key_vault.kv : env => kv.vault_uri
  } : {
    "single" = azurerm_key_vault.kv[""].vault_uri
  }
}

# Data Factory outputs for each environment
output "data_factories" {
  description = "Data Factory details for each environment or single data factory"
  value = var.create_per_env ? {
    for env, adf in azurerm_data_factory.adf : env => {
      name = adf.name
      id   = adf.id
    }
  } : {
    "single" = {
      name = azurerm_data_factory.adf[""].name
      id   = azurerm_data_factory.adf[""].id
    }
  }
}

output "data_factory_names" {
  description = "Data Factory names for each environment or single data factory"
  value = var.create_per_env ? {
    for env, adf in azurerm_data_factory.adf : env => adf.name
  } : {
    "single" = azurerm_data_factory.adf[""].name
  }
}

output "data_factory_urls" {
  description = "Data Factory URLs for each environment or single data factory"
  value = var.create_per_env ? {
    for env, adf in azurerm_data_factory.adf : env => "https://${adf.name}.azurewebsites.net"
  } : {
    "single" = "https://${azurerm_data_factory.adf[""].name}.azurewebsites.net"
  }
}

# Resource Group outputs
output "resource_groups_per_env" {
  description = "Resource groups created for each environment"
  value = var.create_per_env ? {
    for env, rg in azurerm_resource_group.rg_per_env : env => {
      name     = rg.name
      location = rg.location
      id       = rg.id
    }
  } : {}
}

output "resource_group_shared" {
  description = "Shared resource group for common resources"
  value = var.create_per_env ? {
    name     = local.resource_group_shared_name
    location = local.resource_group_shared_location
  } : {
    name     = azurerm_resource_group.rg_shared[0].name
    location = azurerm_resource_group.rg_shared[0].location
    id       = azurerm_resource_group.rg_shared[0].id
  }
}

# Existing shared resource group output (for backward compatibility)
output "resource_group_all" {
  description = "Existing shared resource group for common resources (AKS, Storage, etc.)"
  value = {
    name     = local.resource_group_all_name
    location = local.resource_group_all_location
    id       = local.resource_group_all_id
  }
}