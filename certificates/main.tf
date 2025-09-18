terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Kubernetes provider configuration using AKS cluster credentials
provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.aks.kube_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
}

# Helm provider configuration using AKS cluster credentials
provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.aks.kube_config[0].host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config[0].cluster_ca_certificate)
  }
}

# Data source to get current Azure client configuration (for tenant ID)
data "azurerm_client_config" "current" {}

# Data source to get the existing AKS cluster
data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  resource_group_name = var.shared_resource_group_name
}

# Data source to get the existing Key Vault
data "azurerm_key_vault" "kv" {
  for_each            = var.create_per_env ? toset(var.environments) : toset([""])
  name                = var.create_per_env ? "${var.key_vault_short_name}-${var.project_name}-${each.value}-${var.short_location}-001" : var.key_vault_name
  resource_group_name = var.create_per_env ? var.resource_groups_per_env[each.value] : var.shared_resource_group_name
}

# Install cert-manager for automatic certificate management
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "global.leaderElection.namespace"
    value = "cert-manager"
  }

  depends_on = [data.azurerm_kubernetes_cluster.aks]
}

# Install Azure Key Vault Secrets Store CSI Driver Provider
resource "helm_release" "azure_key_vault_csi_driver" {
  name       = "csi"
  repository = "https://azure.github.io/secrets-store-csi-driver-provider-azure/charts"
  chart      = "csi-secrets-store-provider-azure"
  version    = "1.6.0"  # Latest available version
  namespace  = "kube-system"

  set {
    name  = "controller.usePodIdentity"
    value = "false"
  }

  set {
    name  = "controller.useVMManagedIdentity"
    value = "true"
  }

  set {
    name  = "controller.userAssignedIdentityID"
    value = data.azurerm_kubernetes_cluster.aks.identity[0].principal_id
  }

  depends_on = [data.azurerm_kubernetes_cluster.aks]
  
  timeout = 600 # 10 minutes
}

# Create RBAC resources for secrets-store-csi-driver
resource "kubernetes_cluster_role" "secrets_store_csi_driver" {
  metadata {
    name = "secrets-store-csi-driver"
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  depends_on = [helm_release.azure_key_vault_csi_driver]
}

resource "kubernetes_cluster_role_binding" "secrets_store_csi_driver" {
  metadata {
    name = "secrets-store-csi-driver"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.secrets_store_csi_driver.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "secrets-store-csi-driver"
    namespace = "kube-system"
  }

  depends_on = [kubernetes_cluster_role.secrets_store_csi_driver]
}

# AKS access policies are managed in the main key-vault.tf file
# This module only handles certificate file operations and Kubernetes resources
# The current_user_kv_access policy is managed by the main configuration

# Import the certificate into Key Vault for each environment
resource "azurerm_key_vault_certificate" "wildcard_cert" {
  for_each      = var.create_per_env ? toset(var.environments) : toset([""])
  name          = var.certificate_name
  key_vault_id  = data.azurerm_key_vault.kv[each.value].id

  certificate {
    contents = base64encode("${file("${path.module}/${var.private_key_file_path}")}\n${file("${path.module}/${var.certificate_file_path}")}")
    password = ""
  }

  depends_on = [data.azurerm_key_vault.kv]
}

# Store the certificate chain as a separate secret for completeness for each environment
resource "azurerm_key_vault_secret" "wildcard_cert_chain" {
  for_each      = var.create_per_env ? toset(var.environments) : toset([""])
  name          = var.certificate_chain_name
  value         = file("${path.module}/${var.certificate_chain_file_path}")
  key_vault_id  = data.azurerm_key_vault.kv[each.value].id

  depends_on = [data.azurerm_key_vault.kv]
}

# Store the private key as a secret in Key Vault for each environment
resource "azurerm_key_vault_secret" "wildcard_private_key" {
  for_each      = var.create_per_env ? toset(var.environments) : toset([""])
  name          = var.private_key_name
  value         = file("${path.module}/${var.private_key_file_path}")
  key_vault_id  = data.azurerm_key_vault.kv[each.value].id

  depends_on = [data.azurerm_key_vault.kv]
}



# Create the same SecretProviderClass for dev namespace
resource "kubernetes_manifest" "secret_provider_class_dev" {
  for_each = var.create_per_env ? toset(["dev"]) : toset([])
  
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "azure-kvname-wildcard-cert"
      namespace = "dev"
    }
    spec = {
      provider = "azure"
      secretObjects = [
        {
          secretName = "wildcard-tls-from-kv"
          type       = "kubernetes.io/tls"
          data = [
            {
              key        = "tls.crt"
              objectName = var.certificate_name
            },
            {
              key        = "tls.key"
              objectName = var.private_key_name
            }
          ]
        }
      ]
      parameters = {
        usePodIdentity = "false"
        useVMManagedIdentity = "true"
        userAssignedIdentityID = data.azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id
        keyvaultName = data.azurerm_key_vault.kv[each.key].name
        objects = "array:\n  - |\n    objectName: ${var.certificate_name}\n    objectType: secret\n  - |\n    objectName: ${var.private_key_name}\n    objectType: secret\n  - |\n    objectName: ${var.certificate_chain_name}\n    objectType: secret"
        tenantID = data.azurerm_client_config.current.tenant_id
      }
    }
  }

  depends_on = [helm_release.azure_key_vault_csi_driver, kubernetes_cluster_role_binding.secrets_store_csi_driver]
  
  # Wait for the CRD to be available
  timeouts {
    create = "10m"
  }
}

# Create the same SecretProviderClass for test namespace
resource "kubernetes_manifest" "secret_provider_class_test" {
  for_each = var.create_per_env ? toset(["test"]) : toset([])
  
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "azure-kvname-wildcard-cert"
      namespace = "test"
    }
    spec = {
      provider = "azure"
      secretObjects = [
        {
          secretName = "wildcard-tls-from-kv"
          type       = "kubernetes.io/tls"
          data = [
            {
              key        = "tls.crt"
              objectName = var.certificate_name
            },
            {
              key        = "tls.key"
              objectName = var.private_key_name
            }
          ]
        }
      ]
      parameters = {
        usePodIdentity = "false"
        useVMManagedIdentity = "true"
        userAssignedIdentityID = data.azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id
        keyvaultName = data.azurerm_key_vault.kv[each.key].name
        objects = "array:\n  - |\n    objectName: ${var.certificate_name}\n    objectType: secret\n  - |\n    objectName: ${var.private_key_name}\n    objectType: secret\n  - |\n    objectName: ${var.certificate_chain_name}\n    objectType: secret"
        tenantID = data.azurerm_client_config.current.tenant_id
      }
    }
  }

  depends_on = [helm_release.azure_key_vault_csi_driver, kubernetes_cluster_role_binding.secrets_store_csi_driver]
  
  # Wait for the CRD to be available
  timeouts {
    create = "10m"
  }
}

# Create the same SecretProviderClass for stage namespace
resource "kubernetes_manifest" "secret_provider_class_stage" {
  for_each = var.create_per_env ? toset(["stage"]) : toset([])
  
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "azure-kvname-wildcard-cert"
      namespace = "stage"
    }
    spec = {
      provider = "azure"
      secretObjects = [
        {
          secretName = "wildcard-tls-from-kv"
          type       = "kubernetes.io/tls"
          data = [
            {
              key        = "tls.crt"
              objectName = var.certificate_name
            },
            {
              key        = "tls.key"
              objectName = var.private_key_name
            }
          ]
        }
      ]
      parameters = {
        usePodIdentity = "false"
        useVMManagedIdentity = "true"
        userAssignedIdentityID = data.azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id
        keyvaultName = data.azurerm_key_vault.kv[each.key].name
        objects = "array:\n  - |\n    objectName: ${var.certificate_name}\n    objectType: secret\n  - |\n    objectName: ${var.private_key_name}\n    objectType: secret\n  - |\n    objectName: ${var.certificate_chain_name}\n    objectType: secret"
        tenantID = data.azurerm_client_config.current.tenant_id
      }
    }
  }

  depends_on = [helm_release.azure_key_vault_csi_driver, kubernetes_cluster_role_binding.secrets_store_csi_driver]
  
  # Wait for the CRD to be available
  timeouts {
    create = "10m"
  }
}

# Create the same SecretProviderClass for stage-uat namespace
resource "kubernetes_manifest" "secret_provider_class_stage_uat" {
  for_each = var.create_per_env ? toset(["stage-uat"]) : toset([])
  
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "azure-kvname-wildcard-cert"
      namespace = "stage-uat"
    }
    spec = {
      provider = "azure"
      secretObjects = [
        {
          secretName = "wildcard-tls-from-kv"
          type       = "kubernetes.io/tls"
          data = [
            {
              key        = "tls.crt"
              objectName = var.certificate_name
            },
            {
              key        = "tls.key"
              objectName = var.private_key_name
            }
          ]
        }
      ]
      parameters = {
        usePodIdentity = "false"
        useVMManagedIdentity = "true"
        userAssignedIdentityID = data.azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id
        keyvaultName = data.azurerm_key_vault.kv[each.key].name
        objects = "array:\n  - |\n    objectName: ${var.certificate_name}\n    objectType: secret\n  - |\n    objectName: ${var.private_key_name}\n    objectType: secret\n  - |\n    objectName: ${var.certificate_chain_name}\n    objectType: secret"
        tenantID = data.azurerm_client_config.current.tenant_id
      }
    }
  }

  depends_on = [helm_release.azure_key_vault_csi_driver, kubernetes_cluster_role_binding.secrets_store_csi_driver]
  
  # Wait for the CRD to be available
  timeouts {
    create = "10m"
  }
}


# Create the same SecretProviderClass for prod namespace
resource "kubernetes_manifest" "secret_provider_class_prod" {
  for_each = var.create_per_env ? toset(["prod"]) : toset([])
  
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "azure-kvname-wildcard-cert"
      namespace = "prod"
    }
    spec = {
      provider = "azure"
      secretObjects = [
        {
          secretName = "wildcard-tls-from-kv"
          type       = "kubernetes.io/tls"
          data = [
            {
              key        = "tls.crt"
              objectName = var.certificate_name
            },
            {
              key        = "tls.key"
              objectName = var.private_key_name
            }
          ]
        }
      ]
      parameters = {
        usePodIdentity = "false"
        useVMManagedIdentity = "true"
        userAssignedIdentityID = data.azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id
        keyvaultName = data.azurerm_key_vault.kv[each.key].name
        objects = "array:\n  - |\n    objectName: ${var.certificate_name}\n    objectType: secret\n  - |\n    objectName: ${var.private_key_name}\n    objectType: secret\n  - |\n    objectName: ${var.certificate_chain_name}\n    objectType: secret"
        tenantID = data.azurerm_client_config.current.tenant_id
      }
    }
  }

  depends_on = [helm_release.azure_key_vault_csi_driver, kubernetes_cluster_role_binding.secrets_store_csi_driver]
  
  # Wait for the CRD to be available
  timeouts {
    create = "10m"
  }
}

# Create SecretProviderClass for single key vault when create_per_env is false
resource "kubernetes_manifest" "secret_provider_class_single" {
  count = var.create_per_env ? 0 : 1
  
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"
    metadata = {
      name      = "azure-kvname-wildcard-cert"
      namespace = "default"
    }
    spec = {
      provider = "azure"
      secretObjects = [
        {
          secretName = "wildcard-tls-from-kv"
          type       = "kubernetes.io/tls"
          data = [
            {
              key        = "tls.crt"
              objectName = var.certificate_name
            },
            {
              key        = "tls.key"
              objectName = var.private_key_name
            }
          ]
        }
      ]
      parameters = {
        usePodIdentity = "false"
        useVMManagedIdentity = "true"
        userAssignedIdentityID = data.azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id
        keyvaultName = data.azurerm_key_vault.kv[""].name
        objects = "array:\n  - |\n    objectName: ${var.certificate_name}\n    objectType: secret\n  - |\n    objectName: ${var.private_key_name}\n    objectType: secret\n  - |\n    objectName: ${var.certificate_chain_name}\n    objectType: secret"
        tenantID = data.azurerm_client_config.current.tenant_id
      }
    }
  }

  depends_on = [helm_release.azure_key_vault_csi_driver, kubernetes_cluster_role_binding.secrets_store_csi_driver]
  
  # Wait for the CRD to be available
  timeouts {
    create = "10m"
  }
}
