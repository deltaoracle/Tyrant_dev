# Deployment Guide

This guide explains how to deploy the infrastructure when you have Terraform files organized in different folders.

## 📁 Current Structure

```
Infrastructure/
├── main.tf                    # Main infrastructure
├── variables.tf               # Main variables
├── networking.tf              # Network resources
├── kubernetes.tf              # AKS cluster
├── api-management.tf          # API Management
├── azure-pipelines.yml        # Main pipeline
└── chatbot/
    ├── main.tf                # Chatbot infrastructure
    ├── variables.tf           # Chatbot variables
    ├── outputs.tf             # Chatbot outputs
    ├── README.md              # Chatbot documentation
    └── azure-pipelines-chatbot.yml  # Chatbot pipeline
```

## 🚀 Deployment Options

### Option 1: Multi-Stage Pipeline (Recommended)

The updated `azure-pipelines.yml` now supports multi-stage deployment:

1. **Backend Setup** - Creates backend infrastructure
2. **Main Infrastructure** - Deploys core infrastructure (AKS, API Management, etc.)
3. **Chatbot Infrastructure** - Deploys chatbot resources

**Benefits:**
- ✅ Single pipeline for all infrastructure
- ✅ Proper dependency management
- ✅ Separate state files for each component
- ✅ Easy to understand and maintain

**Usage:**
```bash
# Pipeline will automatically run when you push to main branch
git push origin main
```

### Option 2: Separate Pipelines

You can also use separate pipelines for independent deployments:

1. **Main Pipeline** (`azure-pipelines.yml`) - Deploys core infrastructure
2. **Chatbot Pipeline** (`chatbot/azure-pipelines-chatbot.yml`) - Deploys only chatbot resources

**Benefits:**
- ✅ Independent deployments
- ✅ Faster chatbot deployments
- ✅ Path-based triggers (only runs when chatbot files change)

**Usage:**
```bash
# Deploy only chatbot changes
git push origin main  # Only triggers if chatbot/ files changed
```

## 🔧 Manual Deployment

### Deploy Main Infrastructure

```bash
# Navigate to root directory
cd Infrastructure

# Initialize Terraform
terraform init \
  -backend-config="resource_group_name=rg-maincluster-all-weu-001" \
  -backend-config="storage_account_name=saixmallweu001" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=main-infrastructure.terraform.tfstate" \
  -backend-config="subscription_id=YOUR_SUBSCRIPTION_ID"

# Plan and apply
terraform plan -out=tfplan
terraform apply tfplan
```

### Deploy Chatbot Infrastructure

```bash
# Navigate to chatbot directory
cd Infrastructure/chatbot

# Initialize Terraform
terraform init \
  -backend-config="resource_group_name=rg-maincluster-all-weu-001" \
  -backend-config="storage_account_name=saixmallweu001" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=chatbot-infrastructure.terraform.tfstate" \
  -backend-config="subscription_id=YOUR_SUBSCRIPTION_ID"

# Plan and apply
terraform plan -out=tfplan
terraform apply tfplan
```

## 📊 State Management

### State Files

- **Main Infrastructure**: `main-infrastructure.terraform.tfstate`
- **Chatbot Infrastructure**: `chatbot-infrastructure.terraform.tfstate`

### Backend Storage

Both use the same Azure Storage backend:
- **Resource Group**: `rg-maincluster-all-weu-001`
- **Storage Account**: `saixmallweu001`
- **Container**: `tfstate`

## 🔄 CI/CD Pipeline Variables

Ensure your Azure DevOps pipeline variable group `terraform-pipeline` contains:

```yaml
ARM_CLIENT_ID: "your-service-principal-client-id"
ARM_CLIENT_SECRET: "your-service-principal-secret"
ARM_SUBSCRIPTION_ID: "your-subscription-id"
ARM_TENANT_ID: "your-tenant-id"
```

## 🎯 Best Practices

### 1. State File Separation
- Keep separate state files for different components
- Prevents conflicts and allows independent deployments

### 2. Dependency Management
- Main infrastructure must be deployed before chatbot
- Use pipeline dependencies to ensure proper order

### 3. Environment Variables
- Use consistent naming for environment variables
- Store sensitive values in Azure DevOps variable groups

### 4. Backend Configuration
- Use the same backend storage for all components
- Different state file keys prevent conflicts

### 5. Network Security Groups
- Use user-managed NSGs for predictable naming
- Share NSGs between related services (AKS and API Management)
- Follow Azure security best practices for NSG rules

## 🚨 Troubleshooting

### Common Issues

1. **State File Conflicts**
   - Ensure different state file keys for each component
   - Check backend configuration in each directory

2. **Dependency Errors**
   - Verify main infrastructure is deployed first
   - Check that required resources exist

3. **Pipeline Failures**
   - Verify Azure DevOps variable group exists
   - Check service principal permissions
   - Ensure backend storage exists

### Debug Commands

```bash
# Check Terraform state
terraform state list

# Validate configuration
terraform validate

# Check format
terraform fmt -check -recursive

# Show plan details
terraform plan -detailed-exitcode
```

## 📝 Next Steps

1. **Choose Deployment Option**: Decide between multi-stage or separate pipelines
2. **Configure Variables**: Update `terraform.tfvars` files as needed
3. **Test Deployment**: Run a test deployment in a non-production environment
4. **Monitor**: Set up monitoring and alerting for the infrastructure
5. **Document**: Update documentation as infrastructure evolves 