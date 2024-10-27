# Define the input variables
variable "ssh_public_key" {}
variable "subscription_id" {}

# Specify the required provider
provider "azurerm" {
  features {}
}
# provider "azurerm" {
#   features {}
#   client_id       = var.azure_client_id
#   client_secret   = var.azure_client_secret
#   subscription_id = var.azure_subscription_id
#   tenant_id       = var.azure_tenant_id
# }

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "tf-resource-group"  # Change this to your desired resource group name
  location = "East US"                 # Change to your desired location
}

# Virtual Network 
resource "azurerm_virtual_network" "vnet" {
  name                = "tf-vnet"  # Change to your desired virtual network name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]  # Define the address space for the VNet
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "tf-subnet"  # Change to your desired subnet name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]    # Define the address range for the subnet
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "tf-nic"  # Change to your desired NIC name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"  # Name of the IP configuration
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"   # Dynamic IP allocation
  }
}

# Virtual Machine
resource "azurerm_virtual_machine" "vm" {
  name                  = "tf-vm"  # Change to your desired VM name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_B1s"  # Change to your desired VM size

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "example-os-disk"  # Change to your desired OS disk name
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"      # Use standard HDD
  }

  os_profile {
    computer_name  = "tf_admin"             # Change to your desired hostname
    admin_username = "admin"            # Change to your desired admin username
  }

  os_profile_linux_config {
    disable_password_authentication = true  # Disable password authentication
    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"  # Path where the public key will be placed
      key_data = var.ssh_public_key  # Use the public SSH key passed as a variable
    }
  }
}
