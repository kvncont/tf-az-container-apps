terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.84.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "container_apps_solution" {
  source        = "../"
  solution_name = "kvncont2"
  location      = "eastus2"
}
