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

variable "rg_short_name" {
  description = "Short name specifically for Resource Group resources (e.g., 'rg')"
  type        = string
  default     = "rg"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "ixm"
}

variable "environments" {
  description = "Array of environment names to create resources for"
  type        = list(string)
  default     = ["dev", "test", "stage", "stage-uat", "prod"]
}

variable "create_per_env" {
  description = "If true, create separate key vaults for each environment. If false, create a single key vault."
  type        = bool
  default     = true
}

variable "key_vault_name" {
  description = "Name of the Key Vault (used when create_per_env is false)"
  type        = string
  default     = "kv-ixm-weu-001"
}

# Shared Resource Group (from main infrastructure)
variable "shared_resource_group_name" {
  description = "Name of the shared resource group from main infrastructure (used when create_per_env is false)"
  type        = string
}

variable "resource_groups_per_env" {
  description = "Map of environment-specific resource group names (used when create_per_env is true)"
  type        = map(string)
  default     = {}
}

# AKS Configuration
variable "aks_name" {
  description = "Name of the AKS cluster (format: aks-ixm-all-weu-001)"
  type        = string
}

# Certificate Configuration
variable "certificate_name" {
  description = "Certificate name in Key Vault"
  type        = string
  default     = "wildcard-ixm-cert"
}

variable "certificate_chain_name" {
  description = "Certificate chain name in Key Vault"
  type        = string
  default     = "wildcard-ixm-cert-chain"
}

variable "private_key_name" {
  description = "Private key name in Key Vault"
  type        = string
  default     = "wildcard-ixm-private-key"
}

variable "certificate_file_path" {
  description = "Path to certificate file"
  type        = string
  default     = "csr-files/STAR_revenue_ai.crt"
}

variable "private_key_file_path" {
  description = "Path to private key file"
  type        = string
  default     = "csr-files/private.key"
}

variable "certificate_chain_file_path" {
  description = "Path to certificate chain file"
  type        = string
  default     = "csr-files/STAR_revenue_ai.ca-bundle"
}
