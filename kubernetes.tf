resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = local.resource_group_all_location
  resource_group_name = local.resource_group_all_name
  dns_prefix          = "aksdns"

  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = var.aks_vm_size
    max_pods   = var.aks_max_pods

    temporary_name_for_rotation = "temporary"
    vnet_subnet_id              = azurerm_subnet.aks_subnet_new.id
  }

  identity {
    type = "SystemAssigned"
  }

  sku_tier = var.aks_sku_tier

  network_profile {
    network_plugin    = var.aks_network_plugin
    load_balancer_sku = var.aks_load_balancer_sku
    network_policy    = var.aks_network_policy
    service_cidr      = var.aks_service_cidr
    dns_service_ip    = var.aks_dns_service_ip
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id
  }

  node_resource_group = var.aks_managed_resource_group_name

  depends_on = [
    azurerm_subnet.aks_subnet_new,
    azurerm_network_security_group.aks_nsg,
    azurerm_subnet_network_security_group_association.aks_subnet_nsg
  ]
}

# Grant AKS managed identity AcrPull role on ACR
resource "azurerm_role_assignment" "aks_acr_pull_new" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
  # Add a depends_on to ensure the ACR is created before the role assignment
  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Grant AKS managed identity Contributor role on Application Gateway
resource "azurerm_role_assignment" "aks_appgw_contributor" {
  scope                = azurerm_application_gateway.appgw.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Grant AKS managed identity Contributor role on Application Gateway subnet
resource "azurerm_role_assignment" "aks_appgw_subnet_contributor" {
  scope                = azurerm_subnet.app_gateway_subnet.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# Grant AKS managed identity Contributor role on Application Gateway resource group
resource "azurerm_role_assignment" "aks_appgw_rg_contributor" {
  scope                = local.resource_group_all_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id

  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "kubernetes_namespace" "dev" {
  metadata {
    name = "dev"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "kubernetes_namespace" "test" {
  metadata {
    name = "test"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "kubernetes_namespace" "stage" {
  metadata {
    name = "stage"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "kubernetes_namespace" "stage-uat" {
  metadata {
    name = "stage-uat"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "kubernetes_namespace" "prod" {
  metadata {
    name = "prod"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.nginx_ingress_chart_version
  namespace        = "ingress-nginx"
  create_namespace = true
  timeout          = var.nginx_ingress_timeout
  wait             = true

  set {
    name  = "controller.service.type"
    value = var.nginx_ingress_service_type
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = var.nginx_ingress_external_traffic_policy
  }

  set {
    name  = "controller.replicaCount"
    value = var.nginx_ingress_replica_count
  }

  # Enable default backend
  set {
    name  = "defaultBackend.enabled"
    value = var.nginx_ingress_enable_default_backend
  }

  # Configure ingress class
  set {
    name  = "controller.ingressClassResource.default"
    value = var.nginx_ingress_default_class
  }

  set {
    name  = "controller.ingressClass"
    value = var.nginx_ingress_class_name
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# ACR Pull Secret for dev namespace
resource "kubernetes_secret" "acr_pull_secret_dev" {
  metadata {
    name      = "acr-pull-secret"
    namespace = "dev"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${azurerm_container_registry.acr.login_server}" = {
          auth = base64encode("${azurerm_container_registry.acr.admin_username}:${azurerm_container_registry.acr.admin_password}")
        }
      }
    })
  }

  depends_on = [azurerm_kubernetes_cluster.aks, azurerm_container_registry.acr, kubernetes_namespace.dev]
}

# ACR Pull Secret for test namespace
resource "kubernetes_secret" "acr_pull_secret_test" {
  metadata {
    name      = "acr-pull-secret"
    namespace = "test"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${azurerm_container_registry.acr.login_server}" = {
          auth = base64encode("${azurerm_container_registry.acr.admin_username}:${azurerm_container_registry.acr.admin_password}")
        }
      }
    })
  }

  depends_on = [azurerm_kubernetes_cluster.aks, azurerm_container_registry.acr, kubernetes_namespace.test]
}

resource "kubernetes_secret" "acr_pull_secret_stage" {
  metadata {
    name      = "acr-pull-secret"
    namespace = "stage"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${azurerm_container_registry.acr.login_server}" = {
          auth = base64encode("${azurerm_container_registry.acr.admin_username}:${azurerm_container_registry.acr.admin_password}")
        }
      }
    })
  }

  depends_on = [azurerm_kubernetes_cluster.aks, azurerm_container_registry.acr, kubernetes_namespace.test]
}

resource "kubernetes_secret" "acr_pull_secret_stage_uat" {
  metadata {
    name      = "acr-pull-secret"
    namespace = "stage-uat"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${azurerm_container_registry.acr.login_server}" = {
          auth = base64encode("${azurerm_container_registry.acr.admin_username}:${azurerm_container_registry.acr.admin_password}")
        }
      }
    })
  }

  depends_on = [azurerm_kubernetes_cluster.aks, azurerm_container_registry.acr, kubernetes_namespace.test]
}

# ACR Pull Secret for prod namespace
resource "kubernetes_secret" "acr_pull_secret_prod" {
  metadata {
    name      = "acr-pull-secret"
    namespace = "prod"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${azurerm_container_registry.acr.login_server}" = {
          auth = base64encode("${azurerm_container_registry.acr.admin_username}:${azurerm_container_registry.acr.admin_password}")
        }
      }
    })
  }

  depends_on = [azurerm_kubernetes_cluster.aks, azurerm_container_registry.acr, kubernetes_namespace.prod]
}


