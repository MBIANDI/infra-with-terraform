# Specify the required provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "my_rg" {
  name     = "my-terraform-resources"   # Name of the resource group
  location = "East US"                  # Azure region where you want the resources
}