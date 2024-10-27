# Specify the required provider
provider "azurerm" {
  features {}
  subscription_id = "73517fa6-6488-4aa1-9ab4-a369c6d8afa6"
}

resource "azurerm_resource_group" "my_rg" {
  name     = "my-terraform-resources"   # Name of the resource group
  location = "France Central"                  # Azure region where you want the resources
}