resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = local.resource_group_all_location
  resource_group_name = local.resource_group_all_name
  address_space       = var.vnet_address_space
}


# New AKS subnet with larger CIDR
resource "azurerm_subnet" "aks_subnet_new" {
  name                 = var.aks_subnet_name
  resource_group_name  = local.resource_group_all_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.aks_subnet_address_prefix]
}

resource "azurerm_subnet" "postgres_subnet" {
  name                 = var.postgres_subnet_name
  resource_group_name  = local.resource_group_all_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.postgres_subnet_address_prefix]

  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_private_dns_zone" "postgres" {
  name                = var.postgres_private_dns_zone_name
  resource_group_name = local.resource_group_all_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = var.postgres_private_dns_zone_link_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  resource_group_name   = local.resource_group_all_name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_subnet" "app_gateway_subnet" {
  name                 = var.app_gateway_subnet_name
  resource_group_name  = local.resource_group_all_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.app_gateway_subnet_address_prefix]
}

# User-managed NSG for AKS
resource "azurerm_network_security_group" "aks_nsg" {
  name                = var.nsg_name
  location            = local.resource_group_all_location
  resource_group_name = local.resource_group_all_name

  # Allow all inbound traffic within VNet
  security_rule {
    name                       = "AllowVnetInBound"
    priority                   = var.nsg_allow_vnet_inbound_priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  # Allow Azure Load Balancer health probes
  security_rule {
    name                       = "AllowAzureLoadBalancerInBound"
    priority                   = var.nsg_allow_azure_lb_inbound_priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  # Allow HTTP traffic from Internet (for nginx-ingress LoadBalancer)
  security_rule {
    name                       = "AllowHTTPInbound"
    priority                   = var.nsg_allow_http_inbound_priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow HTTPS traffic from Internet (for nginx-ingress LoadBalancer)
  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = var.nsg_allow_https_inbound_priority
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow DNS queries (UDP 53)
  security_rule {
    name                       = "AllowDNSOutbound"
    priority                   = var.nsg_allow_dns_outbound_priority
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow DNS queries (TCP 53)
  security_rule {
    name                       = "AllowDNSTCPOutbound"
    priority                   = var.nsg_allow_dns_tcp_outbound_priority
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow all outbound traffic
  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = var.nsg_allow_all_outbound_priority
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
    Component   = "aks"
  }
}

# Associate NSG with new AKS subnet
resource "azurerm_subnet_network_security_group_association" "aks_subnet_nsg" {
  subnet_id                 = azurerm_subnet.aks_subnet_new.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

 