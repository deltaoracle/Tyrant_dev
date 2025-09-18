terraform {
  backend "azurerm" {
    # Backend configuration will be provided via command line or environment variables
    # Example: terraform init -backend-config="resource_group_name=rg-terraform-state" -backend-config="storage_account_name=stterraformstate" -backend-config="container_name=tfstate" -backend-config="key=certificates.tfstate"
  }
}
