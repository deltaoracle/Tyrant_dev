# Certificates Module

This Terraform module manages SSL/TLS certificates for the Revenue AI infrastructure. It is designed to be run **independently** after CSR generation and certificate signing, not as part of the main infrastructure deployment.

The module includes:

- **cert-manager**: Automatic certificate management in Kubernetes
- **Azure Key Vault CSI Driver**: Integration between Kubernetes and Azure Key Vault
- **Certificate Storage**: Secure storage of certificates, private keys, and certificate chains in Key Vault
- **Kubernetes Integration**: SecretProviderClass resources for accessing certificates in Kubernetes namespaces

## Features

- Automatic installation and configuration of cert-manager
- Azure Key Vault CSI driver setup with proper RBAC
- Certificate import and storage in Azure Key Vault
- Kubernetes SecretProviderClass resources for dev, test, and prod namespaces
- Note: AKS access policies are managed in the main key-vault.tf file

## Prerequisites

- Existing AKS cluster
- Existing Azure Key Vault
- Certificate files (CRT, private key, CA bundle) in the `csr-files/` directory
- Terraform 1.0+ and Azure provider 3.0+

## Usage

This module is designed to be deployed independently after you have:
1. Generated CSRs and received signed certificates
2. Deployed the main infrastructure (AKS, Key Vault, etc.)
3. Placed certificate files in the `csr-files/` directory

### Configuration

Edit the `terraform.tfvars` file to match your environment:

```hcl
# Short location code for resource naming
short_location = "weu"

# Short name specifically for Key Vault resources
key_vault_short_name = "kv"

# Short name specifically for Resource Group resources
rg_short_name = "rg"

# Project name for resource naming
project_name = "ixm"

# Shared Resource Group (from main infrastructure)
shared_resource_group_name = "rg-maincluster-all-${short_location}-001"

# Environment-specific Resource Groups (from main infrastructure)
resource_groups_per_env = {
  dev  = "rg-ixm-dev-weu-001"
  test = "rg-ixm-test-weu-001"
  prod = "rg-ixm-prod-weu-001"
}

# AKS Configuration
aks_name = "aks-ixm-all-${short_location}-001"

# Environments Configuration
environments = ["dev", "test", "prod"]

# Control whether to create per environment or single key vault
create_per_env = true

# Certificate Configuration (adjust as needed)
certificate_name = "wildcard-ixm-cert"
certificate_chain_name = "wildcard-ixm-cert-chain"
private_key_name = "wildcard-ixm-private-key"
certificate_file_path = "csr-files/STAR_revenue_ai.crt"
private_key_file_path = "csr-files/private.key"
certificate_chain_file_path = "csr-files/STAR_revenue_ai.ca-bundle"
```

## File Structure

```
certificates/
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── terraform.tfvars        # Variable values (customize for your environment)
├── terraform.tfvars.example # Example variable values
├── backend.tf              # Backend configuration
└── README.md               # This file
```

## Certificate Files

Place your certificate files in the `csr-files/` directory:

- `STAR_revenue_ai.crt` - The signed certificate
- `private.key` - The private key
- `STAR_revenue_ai.ca-bundle` - The certificate chain/CA bundle

## Deployment

This module is designed to be deployed **independently** after the main infrastructure is ready.

### Prerequisites
- Main infrastructure deployed (AKS, Key Vault, etc.)
- CSR generated and signed certificate received
- Certificate files placed in `csr-files/` directory
- AKS access policies already configured in Key Vault

### Deployment Steps

1. **Navigate to the certificates directory:**
   ```bash
   cd certificates
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Review the plan:**
   ```bash
   terraform plan
   ```

4. **Apply the configuration:**
   ```bash
   terraform apply
   ```

### Important Notes
- This module references existing AKS and Key Vault resources via data sources
- AKS access policies must be configured in the main `key-vault.tf` before running this module
- The module will fail if the referenced resources don't exist

## Outputs

The module provides several outputs:

- `cert_manager_namespace` - Namespace where cert-manager is installed
- `wildcard_certificate_id` - ID of the certificate in Key Vault
- `secret_provider_class_dev_name` - Name of the SecretProviderClass in dev namespace
- And many more...

## Dependencies

This module **must** be deployed after the main infrastructure is ready:

- ✅ AKS cluster fully provisioned and accessible
- ✅ Azure Key Vault created and accessible
- ✅ AKS access policies configured in Key Vault
- ✅ Certificate files present in the specified paths
- ✅ Terraform state for main infrastructure available

**Note**: This module uses data sources to reference existing resources, so it cannot be deployed before the main infrastructure.

## Security Considerations

- Certificates and private keys are stored securely in Azure Key Vault
- Access is restricted to AKS managed identities (configured in main infrastructure)
- RBAC is properly configured for Kubernetes resources
- No sensitive data is exposed in Terraform outputs
- This module can be deployed independently for better security isolation

## Troubleshooting

### Common Issues

1. **Certificate import fails**: Ensure the certificate files exist and are readable
2. **AKS access denied**: Verify the AKS managed identity has proper permissions on Key Vault (configured in main infrastructure)
3. **SecretProviderClass creation fails**: Check that the Azure Key Vault CSI driver is properly installed
4. **Data source errors**: Ensure main infrastructure is deployed and accessible
5. **Resource not found**: Verify AKS and Key Vault names in terraform.tfvars match your environment

### Debug Commands

```bash
# Check cert-manager status
kubectl get pods -n cert-manager

# Check CSI driver status
kubectl get pods -n kube-system | grep csi

# Verify SecretProviderClass
kubectl get secretproviderclass -n dev
```

## Contributing

When modifying this module:

1. Update the README.md with any new features or changes
2. Ensure all variables have proper descriptions
3. Test the module with different configurations
4. Update the example files if needed
