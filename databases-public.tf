resource "azurerm_postgresql_flexible_server" "postgres_public" {
  name                   = var.postgres_name
  resource_group_name    = local.resource_group_all_name
  location               = local.resource_group_all_location
  version                = var.postgres_version
  administrator_login    = var.postgres_administrator_login
  administrator_password = var.postgres_administrator_password

  zone = var.postgres_zone

  storage_mb = var.postgres_storage_mb
  sku_name   = var.postgres_sku_name

  # Enable public access for easy connection
  public_network_access_enabled = var.postgres_public_network_access_enabled

  # Allow connections from any IP (you can restrict this later)
  maintenance_window {
    day_of_week  = var.postgres_maintenance_window_day
    start_hour   = var.postgres_maintenance_window_hour
    start_minute = var.postgres_maintenance_window_minute
  }

  backup_retention_days = var.postgres_backup_retention_days
}

# Development Databases
resource "azurerm_postgresql_flexible_server_database" "dpnl_ingestion_dev_public" {
  name      = var.database_dev_name
  server_id = azurerm_postgresql_flexible_server.postgres_public.id
  charset   = var.database_charset
}

# Test Databases
resource "azurerm_postgresql_flexible_server_database" "dpnl_ingestion_test_public" {
  name      = var.database_test_name
  server_id = azurerm_postgresql_flexible_server.postgres_public.id
  charset   = var.database_charset
}

# Production Databases
resource "azurerm_postgresql_flexible_server_database" "dpnl_ingestion_prod_public" {
  name      = var.database_prod_name
  server_id = azurerm_postgresql_flexible_server.postgres_public.id
  charset   = var.database_charset
}

# Firewall rule to allow connections from your IP
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all" {
  name             = "allow-all"
  server_id        = azurerm_postgresql_flexible_server.postgres_public.id
  start_ip_address = var.postgres_firewall_start_ip
  end_ip_address   = var.postgres_firewall_end_ip
}

# Private Endpoint for AKS connectivity
resource "azurerm_private_endpoint" "postgres_public" {
  name                = "pe-${var.postgres_name}"
  location            = local.resource_group_all_location
  resource_group_name = local.resource_group_all_name
  subnet_id           = azurerm_subnet.aks_subnet_new.id

  private_service_connection {
    name                           = "psc-${var.postgres_name}"
    private_connection_resource_id = azurerm_postgresql_flexible_server.postgres_public.id
    subresource_names             = ["postgresqlServer"]
    is_manual_connection          = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.postgres.id]
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres]
} 