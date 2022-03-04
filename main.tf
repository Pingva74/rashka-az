# Configure the Azure provider
// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "ddosGroup"
  location = "eastus"
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
    name                = "revenNet1"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_virtual_network" "vnet" {
    name                = "revenNet2"
    address_space       = ["10.1.0.0/16"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_virtual_network" "vnet" {
    name                = "revenNet3"
    address_space       = ["10.2.0.0/16"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

esource "azurerm_linux_virtual_machine" "example" {
  name                = "reven-vm1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.rg.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.4"
    version   = "latest"
  }
}