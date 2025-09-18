# Main Terraform Configuration
# 
# This infrastructure has been organized into logical modules for better maintainability:
#
# - providers.tf          : Terraform configuration and provider blocks
# - resource-groups.tf    : Resource group logic and locals
# - networking.tf         : Virtual network, subnets, and DNS zones
# - application-gateway.tf : Azure Application Gateway with WAF
# - container-registry.tf : Azure Container Registry
# - kubernetes.tf         : AKS cluster, namespaces, and Helm releases
# - databases.tf          : PostgreSQL server and all databases (dev/test/prod)
# - storage.tf            : Storage account resources
# - key-vault.tf          : Key Vault and access policies
# - monitoring.tf         : Log Analytics and Application Insights
# - ai-services.tf        : OpenAI and other AI services
# - roles.tf              : Role assignments and permissions
# - variables.tf          : Input variables
# - output.tf             : Output values
# - backend.tf            : Terraform backend configuration
# - certificates/         : Certificate management module (run separately after CSR generation)
#
# The original database files (database-dev.tf, database-test.tf, database-prod.tf)
# have been consolidated into databases.tf for better organization.
# Certificate management has been moved to a separate module in the certificates/ folder.

# Certificate Management Module
# Note: This module is designed to be run separately after CSR generation
# It handles certificate file operations and Kubernetes resources
# To deploy: cd certificates && terraform init && terraform plan && terraform apply

# Certificate management has been moved to a separate module in the certificates/ folder.
# This module is designed to be run separately after CSR generation.
# To deploy: cd certificates && terraform init && terraform plan && terraform apply