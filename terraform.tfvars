# Short location code for resource naming
short_location = "weu"

# Resource short names for consistent naming
key_vault_short_name = "kv"
data_factory_short_name = "adf"
rg_short_name = "rg"

# Environments to create resources for
environments = ["nprd"]

# Control whether to create per environment or single key vault
create_per_env = true

# Resource names (used when create_per_env is false)
key_vault_name = "kv-ixm-weu-001"
data_factory_name = "adf-ixm-weu-001"

# Project Tags
project_name = "ixm"
environment_name = "all"
# Resource Group Configuration
resource_group_name_all = "rg-maincluster-all-weu-001"
location               = "West Europe"

# Azure Container Registry
acr_name = "acrixmallweu001"

# Azure Kubernetes Service
aks_name                    = "aks-ixm-all-weu-001"
aks_vm_size                = "Standard_B8ms"
aks_node_count             = 1
aks_managed_resource_group_name = "rg-aks-ixm-all-weu-001"

# PostgreSQL Database
postgres_name                    = "postgres-ixm-all-weu-002"
postgres_version                = "16"
postgres_administrator_login    = "pgadmin"
postgres_administrator_password = "ixmP@ssw0rd!"  # Consider changing this in production
postgres_storage_mb             = 2097152
postgres_sku_name              = "B_Standard_B8ms"

# Storage Account
storage_name = "saixmallweu001"

# Monitoring and Logging
appinsights_name     = "ai-ixm-all-weu-001"
log_analytics_name   = "la-ixm-all-weu-001"
log_analytics_sku_name = "PerGB2018"

# Key vault access group
kv_access_group = "acgr-ixm-all-weu-001"

# Azure OpenAI Service
openai_name = "oai-ixm-all-weu-001"

# Virtual Network Configuration
vnet_name           = "vnet-ixm-all-weu-001"
vnet_address_space  = ["10.0.0.0/16"]

# AKS Subnet
aks_subnet_name              = "snet-aks-new"
aks_subnet_address_prefix    = "10.0.16.0/22"

# PostgreSQL Subnet
postgres_subnet_name              = "snet-postgres"
postgres_subnet_address_prefix    = "10.0.2.0/24"
postgres_private_dns_zone_name   = "privatelink.postgres.database.azure.com"
postgres_private_dns_zone_link_name = "postgres-dns-link"

# Application Gateway
app_gateway_name                    = "appgw-ixm-all-weu-001"
app_gateway_sku_name               = "WAF_v2"
app_gateway_sku_tier               = "WAF_v2"
app_gateway_capacity                = 2
app_gateway_subnet_name            = "snet-appgw"
app_gateway_subnet_address_prefix  = "10.0.4.0/24"

# Network Security Group
nsg_name = "nsg-ixm-all-weu-001"

# SKU and Pricing Tier Configuration
acr_sku = "Basic"
storage_account_tier = "Standard"
storage_account_replication_type = "LRS"
key_vault_sku = "standard"
openai_sku = "S0"
aks_sku_tier = "Standard"
aks_load_balancer_sku = "standard"

# AKS Network Configuration
aks_network_plugin = "azure"
aks_network_policy = "azure"
aks_service_cidr = "172.16.0.0/16"
aks_dns_service_ip = "172.16.0.10"
aks_max_pods = 110

# PostgreSQL Configuration
postgres_zone = "1"
postgres_maintenance_window_day = 0
postgres_maintenance_window_hour = 2
postgres_maintenance_window_minute = 0
postgres_backup_retention_days = 7
postgres_public_network_access_enabled = true
postgres_firewall_start_ip = "0.0.0.0"
postgres_firewall_end_ip = "255.255.255.255"

# Database Names
database_dev_name = "dpnl_ingestion_dev"
database_test_name = "dpnl_ingestion_test"
database_prod_name = "dpnl_ingestion_prod"
database_charset = "UTF8"

# Application Gateway Configuration
app_gateway_public_ip_allocation_method = "Static"
app_gateway_public_ip_sku = "Standard"
app_gateway_domain_name_label = "ixm-aks-cluster"
app_gateway_frontend_http_port = 80
app_gateway_backend_http_port = 80
app_gateway_request_timeout = 60
app_gateway_health_probe_interval = 30
app_gateway_health_probe_timeout = 30
app_gateway_health_probe_unhealthy_threshold = 3
app_gateway_health_probe_path = "/healthz"
app_gateway_health_probe_status_codes = ["200-399"]
app_gateway_waf_enabled = true
app_gateway_waf_firewall_mode = "Prevention"
app_gateway_waf_rule_set_type = "OWASP"
app_gateway_waf_rule_set_version = "3.2"
app_gateway_waf_file_upload_limit_mb = 100
app_gateway_waf_max_request_body_size_kb = 128
app_gateway_request_routing_rule_priority = 100

# NGINX Ingress Configuration
nginx_ingress_chart_version = "4.13.0"
nginx_ingress_timeout = 1200
nginx_ingress_replica_count = 1
nginx_ingress_enable_default_backend = true
nginx_ingress_default_class = true
nginx_ingress_class_name = "nginx"
nginx_ingress_service_type = "LoadBalancer"
nginx_ingress_external_traffic_policy = "Local"

# Monitoring Configuration
log_analytics_retention_days = 30
application_insights_type = "web"

# Key Vault Configuration
key_vault_enabled_for_disk_encryption = true
key_vault_soft_delete_retention_days = 7
key_vault_purge_protection_enabled = false
key_vault_network_default_action = "Allow"
key_vault_network_bypass = "AzureServices"

# NSG Security Rules Priority
nsg_allow_vnet_inbound_priority = 100
nsg_allow_azure_lb_inbound_priority = 105
nsg_allow_http_inbound_priority = 200
nsg_allow_https_inbound_priority = 210
nsg_allow_dns_outbound_priority = 110
nsg_allow_dns_tcp_outbound_priority = 115
nsg_allow_all_outbound_priority = 120

# Application Gateway NSG Security Rules Priority
appgw_nsg_http_inbound_priority = 100
appgw_nsg_https_inbound_priority = 110
appgw_nsg_azure_lb_inbound_priority = 120
appgw_nsg_v2_internal_priority = 130
appgw_nsg_v2_health_priority = 140
appgw_nsg_all_outbound_priority = 100

# Temporary placeholder for NGINX IP (should be dynamic)
nginx_ingress_ip_address = "48.216.184.114"
