# Short location variable for consistent naming across resources
variable "short_location" {
  description = "Short location code for resource naming (e.g., 'weu' for West Europe)"
  type        = string
  default     = "weu"
}

variable "key_vault_short_name" {
  description = "Short name specifically for Key Vault resources (e.g., 'kv')"
  type        = string
  default     = "kv"
}

variable "data_factory_short_name" {
  description = "Short name specifically for Data Factory resources (e.g., 'adf')"
  type        = string
  default     = "adf"
}

variable "rg_short_name" {
  description = "Short name specifically for Resource Group resources (e.g., 'rg')"
  type        = string
  default     = "rg"
}

variable "data_factory_name" {
  description = "Data Factory Name (used when create_per_env is false)"
  type        = string
  default     = "adf-ixm-weu-001"
}

variable "environments" {
  description = "Array of environment names to create resources for"
  type        = list(string)
  default     = ["dev", "test", "prod"]
}

variable "create_per_env" {
  description = "If true, create separate key vaults for each environment. If false, create a single key vault."
  type        = bool
  default     = true
}

variable "key_vault_name" {
  description = "Key Vault Name (used when create_per_env is false)"
  type        = string
  default     = "kv-ixm-weu-001"
}

variable "resource_group_name_all" {
  description = "Resource Group name"
  type        = string
  default     = "rg-maincluster-all-weu-001"
}

variable "location" {
  description = "Azure location"
  type        = string
  default     = "West Europe"
}

variable "acr_name" {
  description = "ACR Name"
  type        = string
  default     = "acrixmallweu001"
}

variable "aks_name" {
  description = "AKS Name"
  type        = string
  default     = "aks-ixm-all-weu-001"
}

variable "aks_vm_size" {
  description = "AKS VM size"
  type        = string
  default     = "Standard_B8ms"
}

variable "aks_node_count" {
  description = "Number of nodes in AKS default node pool"
  type        = number
  default     = 1
}

variable "postgres_name" {
  description = "Postgres Name"
  type        = string
  default     = "postgres-ixm-all-weu-002"
}

variable "postgres_version" {
  description = "Postgres version"
  type        = string
  default     = "16"
}

variable "postgres_administrator_login" {
  description = "Postgres administrator login"
  type        = string
  default     = "pgadmin"
}

variable "postgres_administrator_password" {
  description = "Postgres administrator password"
  type        = string
  default     = "ixmP@ssw0rd!"
}

variable "postgres_storage_mb" {
  description = "Postgres sku name"
  type        = number
  default     = 2097152
}

variable "postgres_sku_name" {
  description = "Postgres sku name"
  type        = string
  default     = "B_Standard_B8ms"
}

variable "storage_name" {
  description = "Storage Name"
  type        = string
  default     = "saixmallweu001"
}

variable "appinsights_name" {
  description = "App Insights Name"
  type        = string
  default     = "ai-ixm-all-weu-001"
}

variable "log_analytics_name" {
  description = "Log Analytics Name"
  type        = string
  default     = "la-ixm-all-weu-001"
}

variable "log_analytics_sku_name" {
  description = "Log analytics sku name"
  type        = string
  default     = "PerGB2018"
}

variable "client_id" {
  description = "Azure Service Principal Client ID"
  type        = string
  default     = "a1e27866-040a-492e-bcfc-297ef6403cf6"
}

variable "scope" {
  description = "Subscription scope"
  type        = string
  default     = "/subscriptions/75d61080-36bf-4408-9acf-3416c519c50c"
}

variable "kv_access_group" {
  description = "Key Vault Access user group"
  type        = string
  default     = "acgr-ixm-all-weu-001"
}

variable "openai_name" {
  description = "Azure OpenAI Service Name"
  type        = string
  default     = "oai-ixm-all-weu-001"
}

variable "vnet_name" {
  description = "Virtual Network Name"
  type        = string
  default     = "vnet-ixm-all-weu-001"
}

variable "vnet_address_space" {
  description = "Virtual Network Address Space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_name" {
  description = "AKS Subnet Name"
  type        = string
  default     = "snet-aks-new"
}

variable "aks_subnet_address_prefix" {
  description = "AKS Subnet Address Prefix"
  type        = string
  default     = "10.0.16.0/22"
}

variable "postgres_subnet_name" {
  description = "PostgreSQL Subnet Name"
  type        = string
  default     = "snet-postgres"
}

variable "postgres_subnet_address_prefix" {
  description = "PostgreSQL Subnet Address Prefix"
  type        = string
  default     = "10.0.2.0/24"
}

variable "postgres_private_dns_zone_name" {
  description = "PostgreSQL Private DNS Zone Name"
  type        = string
  default     = "privatelink.postgres.database.azure.com"
}

variable "postgres_private_dns_zone_link_name" {
  description = "PostgreSQL Private DNS Zone VNet Link Name"
  type        = string
  default     = "postgres-dns-link"
}

# Application Gateway variables
variable "app_gateway_name" {
  description = "Application Gateway Name"
  type        = string
  default     = "appgw-ixm-all-weu-001"
}

variable "app_gateway_sku_name" {
  description = "Application Gateway SKU Name"
  type        = string
  default     = "WAF_v2"
}

variable "app_gateway_sku_tier" {
  description = "Application Gateway SKU Tier"
  type        = string
  default     = "WAF_v2"
}

variable "app_gateway_capacity" {
  description = "Application Gateway Capacity"
  type        = number
  default     = 2
}

variable "app_gateway_subnet_name" {
  description = "Application Gateway Subnet Name"
  type        = string
  default     = "snet-appgw"
}

variable "app_gateway_subnet_address_prefix" {
  description = "Application Gateway Subnet Address Prefix"
  type        = string
  default     = "10.0.4.0/24"
}

variable "nsg_name" {
  description = "Network Security Group Name"
  type        = string
  default     = "nsg-ixm-all-weu-001"
}

variable "aks_managed_resource_group_name" {
  description = "AKS Managed Resource Group Name (Azure will create this automatically, but you can influence the naming)"
  type        = string
  default     = "rg-aks-ixm-all-weu-001"
}

# SKU and Pricing Tier Variables
variable "acr_sku" {
  description = "Azure Container Registry SKU"
  type        = string
  default     = "Basic"
}

variable "storage_account_tier" {
  description = "Storage Account tier"
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Storage Account replication type"
  type        = string
  default     = "LRS"
}

variable "key_vault_sku" {
  description = "Key Vault SKU"
  type        = string
  default     = "standard"
}

variable "openai_sku" {
  description = "Azure OpenAI Service SKU"
  type        = string
  default     = "S0"
}

variable "aks_sku_tier" {
  description = "AKS SKU tier"
  type        = string
  default     = "Standard"
}

variable "aks_load_balancer_sku" {
  description = "AKS load balancer SKU"
  type        = string
  default     = "standard"
}

variable "aks_network_plugin" {
  description = "AKS network plugin"
  type        = string
  default     = "azure"
}

variable "aks_network_policy" {
  description = "AKS network policy"
  type        = string
  default     = "azure"
}

variable "aks_service_cidr" {
  description = "AKS service CIDR"
  type        = string
  default     = "172.16.0.0/16"
}

variable "aks_dns_service_ip" {
  description = "AKS DNS service IP"
  type        = string
  default     = "172.16.0.10"
}

variable "aks_max_pods" {
  description = "Maximum number of pods per node"
  type        = number
  default     = 110
}

# Database Configuration Variables
variable "postgres_zone" {
  description = "PostgreSQL availability zone"
  type        = string
  default     = "1"
}

variable "postgres_maintenance_window_day" {
  description = "PostgreSQL maintenance window day (0=Sunday, 1=Monday, etc.)"
  type        = number
  default     = 0
}

variable "postgres_maintenance_window_hour" {
  description = "PostgreSQL maintenance window start hour"
  type        = number
  default     = 2
}

variable "postgres_maintenance_window_minute" {
  description = "PostgreSQL maintenance window start minute"
  type        = number
  default     = 0
}

variable "postgres_backup_retention_days" {
  description = "PostgreSQL backup retention days"
  type        = number
  default     = 7
}

variable "postgres_public_network_access_enabled" {
  description = "Enable public network access for PostgreSQL"
  type        = bool
  default     = true
}

variable "postgres_firewall_start_ip" {
  description = "PostgreSQL firewall start IP address"
  type        = string
  default     = "0.0.0.0"
}

variable "postgres_firewall_end_ip" {
  description = "PostgreSQL firewall end IP address"
  type        = string
  default     = "255.255.255.255"
}

# Database Names
variable "database_dev_name" {
  description = "Development database name"
  type        = string
  default     = "dpnl_ingestion_dev"
}

variable "database_test_name" {
  description = "Test database name"
  type        = string
  default     = "dpnl_ingestion_test"
}

variable "database_prod_name" {
  description = "Production database name"
  type        = string
  default     = "dpnl_ingestion_prod"
}

variable "database_charset" {
  description = "Database character set"
  type        = string
  default     = "UTF8"
}

# Application Gateway Configuration
variable "app_gateway_public_ip_allocation_method" {
  description = "Application Gateway public IP allocation method"
  type        = string
  default     = "Static"
}

variable "app_gateway_public_ip_sku" {
  description = "Application Gateway public IP SKU"
  type        = string
  default     = "Standard"
}

variable "app_gateway_domain_name_label" {
  description = "Application Gateway domain name label"
  type        = string
  default     = "ixm-aks-cluster"
}

variable "app_gateway_frontend_http_port" {
  description = "Application Gateway frontend HTTP port"
  type        = number
  default     = 80
}

variable "app_gateway_backend_http_port" {
  description = "Application Gateway backend HTTP port"
  type        = number
  default     = 80
}

variable "app_gateway_request_timeout" {
  description = "Application Gateway request timeout in seconds"
  type        = number
  default     = 60
}

variable "app_gateway_health_probe_interval" {
  description = "Application Gateway health probe interval in seconds"
  type        = number
  default     = 30
}

variable "app_gateway_health_probe_timeout" {
  description = "Application Gateway health probe timeout in seconds"
  type        = number
  default     = 30
}

variable "app_gateway_health_probe_unhealthy_threshold" {
  description = "Application Gateway health probe unhealthy threshold"
  type        = number
  default     = 3
}

variable "app_gateway_health_probe_path" {
  description = "Application Gateway health probe path"
  type        = string
  default     = "/healthz"
}

variable "app_gateway_health_probe_status_codes" {
  description = "Application Gateway health probe acceptable status codes"
  type        = list(string)
  default     = ["200-399"]
}

variable "app_gateway_waf_enabled" {
  description = "Enable WAF on Application Gateway"
  type        = bool
  default     = true
}

variable "app_gateway_waf_firewall_mode" {
  description = "Application Gateway WAF firewall mode"
  type        = string
  default     = "Prevention"
}

variable "app_gateway_waf_rule_set_type" {
  description = "Application Gateway WAF rule set type"
  type        = string
  default     = "OWASP"
}

variable "app_gateway_waf_rule_set_version" {
  description = "Application Gateway WAF rule set version"
  type        = string
  default     = "3.2"
}

variable "app_gateway_waf_file_upload_limit_mb" {
  description = "Application Gateway WAF file upload limit in MB"
  type        = number
  default     = 100
}

variable "app_gateway_waf_max_request_body_size_kb" {
  description = "Application Gateway WAF max request body size in KB"
  type        = number
  default     = 128
}

variable "app_gateway_request_routing_rule_priority" {
  description = "Application Gateway request routing rule priority"
  type        = number
  default     = 100
}

# NGINX Ingress Configuration
variable "nginx_ingress_chart_version" {
  description = "NGINX Ingress chart version"
  type        = string
  default     = "4.13.0"
}

variable "nginx_ingress_timeout" {
  description = "NGINX Ingress timeout in seconds"
  type        = number
  default     = 1200
}

variable "nginx_ingress_replica_count" {
  description = "NGINX Ingress replica count"
  type        = number
  default     = 1
}

variable "nginx_ingress_enable_default_backend" {
  description = "Enable NGINX Ingress default backend"
  type        = bool
  default     = true
}

variable "nginx_ingress_default_class" {
  description = "Set NGINX Ingress as default class"
  type        = bool
  default     = true
}

variable "nginx_ingress_class_name" {
  description = "NGINX Ingress class name"
  type        = string
  default     = "nginx"
}

variable "nginx_ingress_service_type" {
  description = "NGINX Ingress service type"
  type        = string
  default     = "LoadBalancer"
}

variable "nginx_ingress_external_traffic_policy" {
  description = "NGINX Ingress external traffic policy"
  type        = string
  default     = "Local"
}

# Monitoring Configuration
variable "log_analytics_retention_days" {
  description = "Log Analytics workspace retention in days"
  type        = number
  default     = 30
}

variable "application_insights_type" {
  description = "Application Insights type"
  type        = string
  default     = "web"
}

# Project Tags
variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
  default     = "ixm"
}

variable "environment_name" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "all"
}

# Key Vault Configuration
variable "key_vault_enabled_for_disk_encryption" {
  description = "Enable Key Vault for disk encryption"
  type        = bool
  default     = true
}

variable "key_vault_soft_delete_retention_days" {
  description = "Key Vault soft delete retention days"
  type        = number
  default     = 7
}

variable "key_vault_purge_protection_enabled" {
  description = "Enable Key Vault purge protection"
  type        = bool
  default     = false
}

variable "key_vault_network_default_action" {
  description = "Key Vault network default action"
  type        = string
  default     = "Allow"
}

variable "key_vault_network_bypass" {
  description = "Key Vault network bypass"
  type        = string
  default     = "AzureServices"
}

# NSG Security Rules
variable "nsg_allow_vnet_inbound_priority" {
  description = "NSG allow VNet inbound rule priority"
  type        = number
  default     = 100
}

# Application Gateway NSG Security Rules
variable "appgw_nsg_http_inbound_priority" {
  description = "Application Gateway NSG HTTP inbound rule priority"
  type        = number
  default     = 100
}

variable "appgw_nsg_https_inbound_priority" {
  description = "Application Gateway NSG HTTPS inbound rule priority"
  type        = number
  default     = 110
}

variable "appgw_nsg_azure_lb_inbound_priority" {
  description = "Application Gateway NSG Azure Load Balancer inbound rule priority"
  type        = number
  default     = 120
}

variable "appgw_nsg_v2_internal_priority" {
  description = "Application Gateway NSG v2 internal communication rule priority"
  type        = number
  default     = 130
}

variable "appgw_nsg_v2_health_priority" {
  description = "Application Gateway NSG v2 health monitoring rule priority"
  type        = number
  default     = 140
}

variable "appgw_nsg_all_outbound_priority" {
  description = "Application Gateway NSG all outbound rule priority"
  type        = number
  default     = 100
}

variable "nsg_allow_azure_lb_inbound_priority" {
  description = "NSG allow Azure Load Balancer inbound rule priority"
  type        = number
  default     = 105
}

variable "nsg_allow_http_inbound_priority" {
  description = "NSG allow HTTP inbound rule priority"
  type        = number
  default     = 200
}

variable "nsg_allow_https_inbound_priority" {
  description = "NSG allow HTTPS inbound rule priority"
  type        = number
  default     = 210
}

variable "nsg_allow_dns_outbound_priority" {
  description = "NSG allow DNS outbound rule priority"
  type        = number
  default     = 110
}

variable "nsg_allow_dns_tcp_outbound_priority" {
  description = "NSG allow DNS TCP outbound rule priority"
  type        = number
  default     = 115
}

variable "nsg_allow_all_outbound_priority" {
  description = "NSG allow all outbound rule priority"
  type        = number
  default     = 120
}

# Temporary placeholder for NGINX IP (should be dynamic)
variable "nginx_ingress_ip_address" {
  description = "NGINX Ingress Controller LoadBalancer IP (temporary placeholder)"
  type        = string
  default     = "48.216.184.114"
}