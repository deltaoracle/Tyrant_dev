

# Application Gateway with WAF
resource "azurerm_public_ip" "appgw" {
  name                = "${var.app_gateway_name}-pip"
  location            = local.resource_group_all_location
  resource_group_name = local.resource_group_all_name
  allocation_method   = var.app_gateway_public_ip_allocation_method
  sku                 = var.app_gateway_public_ip_sku
  domain_name_label   = var.app_gateway_domain_name_label

  tags = {
    Environment = var.environment_name
    Project     = var.project_name
    Component   = "application-gateway"
  }
}

resource "azurerm_application_gateway" "appgw" {
  name                = var.app_gateway_name
  location            = local.resource_group_all_location
  resource_group_name = local.resource_group_all_name

  sku {
    name     = var.app_gateway_sku_name
    tier     = var.app_gateway_sku_tier
    capacity = var.app_gateway_capacity
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = azurerm_subnet.app_gateway_subnet.id
  }

  frontend_port {
    name = "http-port"
    port = var.app_gateway_frontend_http_port
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  # HTTP Listener
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-configuration"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  # Request Routing Rule for HTTP traffic to backend
  request_routing_rule {
    name                       = "http-to-backend"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
    priority                   = var.app_gateway_request_routing_rule_priority
  }

  # Backend Address Pool (configured with NGINX Ingress LoadBalancer IP)
  backend_address_pool {
    name         = "backend-pool"
    ip_addresses = [var.nginx_ingress_ip_address]  # NGINX Ingress Controller LoadBalancer IP
  }

  # Health Probe for nginx-ingress
  probe {
    name                = "nginx-health-probe"
    protocol            = "Http"
    path                = var.app_gateway_health_probe_path
    host                = var.nginx_ingress_ip_address
    interval            = var.app_gateway_health_probe_interval
    timeout             = var.app_gateway_health_probe_timeout
    unhealthy_threshold = var.app_gateway_health_probe_unhealthy_threshold
    
    match {
      status_code = var.app_gateway_health_probe_status_codes
    }
  }

  # Backend HTTP Settings
  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = var.app_gateway_backend_http_port
    protocol              = "Http"
    request_timeout       = var.app_gateway_request_timeout
    probe_name           = "nginx-health-probe"
  }



  # WAF Configuration
  waf_configuration {
    enabled                  = var.app_gateway_waf_enabled
    firewall_mode            = var.app_gateway_waf_firewall_mode
    rule_set_type            = var.app_gateway_waf_rule_set_type
    rule_set_version         = var.app_gateway_waf_rule_set_version
    file_upload_limit_mb     = var.app_gateway_waf_file_upload_limit_mb
    max_request_body_size_kb = var.app_gateway_waf_max_request_body_size_kb

    # WAF Rules
    disabled_rule_group {
      rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
      rules           = []
    }

    disabled_rule_group {
      rule_group_name = "REQUEST-943-APPLICATION-ATTACK-SESSION-FIXATION"
      rules           = []
    }
  }

  tags = {
    Environment = var.environment_name
    Project     = var.project_name
    Component   = "application-gateway"
  }

  depends_on = [
    azurerm_subnet.app_gateway_subnet,
    azurerm_subnet_network_security_group_association.appgw_subnet_nsg
  ]
}

# Network Security Group for Application Gateway
resource "azurerm_network_security_group" "appgw_nsg" {
  name                = "${var.app_gateway_name}-nsg"
  location            = local.resource_group_all_location
  resource_group_name = local.resource_group_all_name

  # Allow HTTP traffic
  security_rule {
    name                       = "AllowHTTPInbound"
    priority                   = var.appgw_nsg_http_inbound_priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow HTTPS traffic
  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = var.appgw_nsg_https_inbound_priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow Azure Load Balancer health probes
  security_rule {
    name                       = "AllowAzureLoadBalancerInBound"
    priority                   = var.appgw_nsg_azure_lb_inbound_priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  # Allow Application Gateway v2 internal communication (required for v2 SKU)
  security_rule {
    name                       = "AllowAppGatewayV2Internal"
    priority                   = var.appgw_nsg_v2_internal_priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  # Allow Application Gateway v2 health monitoring
  security_rule {
    name                       = "AllowAppGatewayV2Health"
    priority                   = var.appgw_nsg_v2_health_priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow all outbound traffic
  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = var.appgw_nsg_all_outbound_priority
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment_name
    Project     = var.project_name
    Component   = "application-gateway"
  }
}

# Associate NSG with Application Gateway subnet
resource "azurerm_subnet_network_security_group_association" "appgw_subnet_nsg" {
  subnet_id                 = azurerm_subnet.app_gateway_subnet.id
  network_security_group_id = azurerm_network_security_group.appgw_nsg.id
} 