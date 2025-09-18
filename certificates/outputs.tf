# Certificate Management Outputs
output "cert_manager_namespace" {
  description = "Namespace where cert-manager is installed"
  value       = "cert-manager"
}

output "cert_manager_status" {
  description = "Status of cert-manager installation"
  value       = helm_release.cert_manager.status
}

output "azure_key_vault_csi_driver_status" {
  description = "Status of Azure Key Vault CSI driver installation"
  value       = helm_release.azure_key_vault_csi_driver.status
}

output "secrets_store_csi_driver_status" {
  description = "Status of secrets-store-csi-driver RBAC setup"
  value       = "Configured"
}

# Key Vault Certificate Outputs - Environment-specific when create_per_env is true
output "wildcard_certificate_ids" {
  description = "IDs of the wildcard certificates in Key Vault for each environment"
  value = {
    for env, cert in azurerm_key_vault_certificate.wildcard_cert : env => cert.id
  }
}

output "wildcard_certificate_versions" {
  description = "Versions of the wildcard certificates in Key Vault for each environment"
  value = {
    for env, cert in azurerm_key_vault_certificate.wildcard_cert : env => cert.version
  }
}

output "wildcard_certificate_secret_ids" {
  description = "Secret IDs of the wildcard certificates in Key Vault for each environment"
  value = {
    for env, cert in azurerm_key_vault_certificate.wildcard_cert : env => cert.secret_id
  }
}

output "wildcard_certificate_chain_secret_ids" {
  description = "Secret IDs of the wildcard certificate chains in Key Vault for each environment"
  value = {
    for env, secret in azurerm_key_vault_secret.wildcard_cert_chain : env => secret.id
  }
}

output "wildcard_private_key_secret_ids" {
  description = "Secret IDs of the wildcard private keys in Key Vault for each environment"
  value = {
    for env, secret in azurerm_key_vault_secret.wildcard_private_key : env => secret.id
  }
}

# Single certificate outputs for when create_per_env is false
output "wildcard_certificate_id" {
  description = "ID of the wildcard certificate in Key Vault (single instance)"
  value       = var.create_per_env ? null : azurerm_key_vault_certificate.wildcard_cert[""].id
}

output "wildcard_certificate_version" {
  description = "Version of the wildcard certificate in Key Vault (single instance)"
  value       = var.create_per_env ? null : azurerm_key_vault_certificate.wildcard_cert[""].version
}

output "wildcard_certificate_secret_id" {
  description = "Secret ID of the wildcard certificate in Key Vault (single instance)"
  value       = var.create_per_env ? null : azurerm_key_vault_certificate.wildcard_cert[""].secret_id
}

output "wildcard_certificate_chain_secret_id" {
  description = "Secret ID of the wildcard certificate chain in Key Vault (single instance)"
  value       = var.create_per_env ? null : azurerm_key_vault_secret.wildcard_cert_chain[""].id
}

output "wildcard_private_key_secret_id" {
  description = "Secret ID of the wildcard private key in Key Vault (single instance)"
  value       = var.create_per_env ? null : azurerm_key_vault_secret.wildcard_private_key[""].id
}

# Kubernetes SecretProviderClass Outputs
output "secret_provider_class_dev_name" {
  description = "Name of the SecretProviderClass in dev namespace"
  value       = var.create_per_env ? kubernetes_manifest.secret_provider_class_dev["dev"].manifest.metadata.name : null
}

output "secret_provider_class_test_name" {
  description = "Name of the SecretProviderClass in test namespace"
  value       = var.create_per_env ? kubernetes_manifest.secret_provider_class_test["test"].manifest.metadata.name : null
}

output "secret_provider_class_stage_name" {
  description = "Name of the SecretProviderClass in stage namespace"
  value       = var.create_per_env ? kubernetes_manifest.secret_provider_class_stage["stage"].manifest.metadata.name : null
}

output "secret_provider_class_stage_uat_name" {
  description = "Name of the SecretProviderClass in stage-uat namespace"
  value       = var.create_per_env ? kubernetes_manifest.secret_provider_class_stage_uat["stage-uat"].manifest.metadata.name : null
}

output "secret_provider_class_prod_name" {
  description = "Name of the SecretProviderClass in prod namespace"
  value       = var.create_per_env ? kubernetes_manifest.secret_provider_class_prod["prod"].manifest.metadata.name : null
}

output "secret_provider_class_single_name" {
  description = "Name of the SecretProviderClass in default namespace (single instance)"
  value       = var.create_per_env ? null : kubernetes_manifest.secret_provider_class_single[0].manifest.metadata.name
}

# Access Policy Outputs
# Note: AKS access policies are managed in the main key-vault.tf file
