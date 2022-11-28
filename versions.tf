terraform {
  required_version = ">=1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.23.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.4.0"
    }
  }
}
