terraform {
  backend "azurerm" {
    # Partial configuration - these will be provided during terraform init
    # resource_group_name  = "rg-maincluster-all-weu-001"
    # storage_account_name = "saixmallweu001"
    # container_name       = "tfstate"
    # key                  = "prod.terraform.tfstate"
    # subscription_id      = "532d2478-8df6-47c7-920e-1035b9b3804c"
  }
}
