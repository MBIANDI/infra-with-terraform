# Define the input variables
variable "ssh_public_key" {}
variable "subscription_id" {}

# Specify the required provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "my_rg" {
  name     = "my-terraform-resources"   # Name of the resource group
  location = "France Central"                  # Azure region where you want the resources
}

# Virtual Network 
resource "azurerm_virtual_network" "vnet" {
  name                = "tf-vnet"  # Change to your desired virtual network name
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
  address_space       = ["10.0.0.0/16"]  # Define the address space for the VNet
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "tf-subnet"  # Change to your desired subnet name
  resource_group_name  = azurerm_resource_group.my_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]    # Define the address range for the subnet
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = "tf-nic"  # Change to your desired NIC name
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name

  ip_configuration {
    name                          = "internal"  # Name of the IP configuration
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"   # Dynamic IP allocation
  }
}

# Virtual Machine
resource "azurerm_virtual_machine" "vm" {
  name                  = "tf-vm"  
  location              = azurerm_resource_group.my_rg.location
  resource_group_name   = azurerm_resource_group.my_rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_B1s"  

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "example-os-disk"  
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"      # Use standard HDD
  }

  os_profile {
    computer_name  = "tf_admin"            
    admin_username = "admin"            
  }

  os_profile_linux_config {
    disable_password_authentication = true  
    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"  # Path where the public key will be placed
      key_data = var.ssh_public_key  # Use the public SSH key passed as a variable
    }
  }
}