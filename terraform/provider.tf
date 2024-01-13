terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.56.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraform-tfstate-rg"
    storage_account_name = "saterraformdevops12"
    container_name       = "tfstate"
    key                  = "azuresweden.tfstate"
  }
}

provider "azurerm" {
  features {
  }
}