# Short location code for resource naming
short_location = "weu"

# Short name specifically for Key Vault resources
key_vault_short_name = "kv"

# Short name specifically for Resource Group resources
rg_short_name = "rg"

# Project name for resource naming
project_name = "ixm"

# Environments to create resources for
environments = ["dev", "test", "stage", "stage-uat", "prod"]

# Control whether to create per environment or single key vault
create_per_env = true

# Shared Resource Group (from main infrastructure)
shared_resource_group_name = "rg-maincluster-all-weu-001"

# Environment-specific Resource Groups (from main infrastructure)
resource_groups_per_env = {
  dev  = "rg-ixm-dev-weu-001"
  test  = "rg-ixm-test-weu-001"
  stage  = "rg-ixm-stage-weu-001"
  stage-uat  = "rg-ixm-stage-uat-weu-001"
  prod  = "rg-ixm-prod-weu-001"
}

# AKS Configuration
aks_name = "aks-ixm-all-weu-001"

# Certificate Configuration
certificate_name = "wildcard-ixm-cert"
certificate_chain_name = "wildcard-ixm-cert-chain"
private_key_name = "wildcard-ixm-private-key"
certificate_file_path = "csr-files/STAR_revenue_ai.crt"
private_key_file_path = "csr-files/private.key"
certificate_chain_file_path = "csr-files/STAR_revenue_ai.ca-bundle"
