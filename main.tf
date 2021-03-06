# Configure the Azure provider
# =============================================================================
# Resources
#
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine
# https://docs.microsoft.com/uk-ua/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure
# =============================================================================

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
resource "azurerm_virtual_network" "vnetA" {
  name                = "${var.prefix}-net"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "vsubA" {
  name                 = "${var.prefix}-subNet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnetA.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "publicIp" {
  name                = "${var.prefix}-PublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "${var.stage}"
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-SecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "${var.stage}"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.prefix}-NicConfiguration"
    subnet_id                     = azurerm_subnet.vsubA.id
    public_ip_address_id          = azurerm_public_ip.publicIp.id
    private_ip_address_allocation = "Dynamic"

  }

  tags = {
    environment = "${var.stage}"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nic2nSG" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create a virtual machines
resource "azurerm_linux_virtual_machine" "vmA" {
  name                = "${var.prefix}-vm1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"

  admin_username = var.username
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = var.username
    public_key = file("${var.public_key}")
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

  provisioner "local-exec" {
    command = "echo $INST_IP >> $HOSTS"

    environment = {
      INST_IP = "${self.public_ip_address}"
      HOSTS   = "inventory/hosts.all"
    }
  }

  # We connect to our instance via Terraform and remotely executes our script using SSH
  provisioner "remote-exec" {
    script = var.script_path

    connection {
      type        = "ssh"
      host        = self.public_ip_address
      user        = var.username
      private_key = file("${var.public_key}")
    }
  }

  tags = {
    environment = "${var.stage}"
  }
}

data "azurerm_public_ip" "public_ip" {
  name                = azurerm_public_ip.publicIp.name
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [azurerm_public_ip.publicIp, azurerm_linux_virtual_machine.vmA]
}

output "ip" {
  value = data.azurerm_public_ip.public_ip.ip_address
}
