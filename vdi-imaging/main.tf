# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    virtual_machine {
      delete_os_disk_on_deletion = true
    }
  }
}

# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.8.0"
    }
  }
}

# Create resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.azure_location
}

# Create VNET
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_prefix}vnet"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.azure_location
}

# Create internal Subnet
resource "azurerm_subnet" "subnet_internal" {
  name                 = "${var.resource_prefix}snet-internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create Public IP for DC VM
resource "azurerm_public_ip" "dc_public_ip" {
  name                = "${var.resource_prefix}pip-dc"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.azure_location
  allocation_method   = "Dynamic"
}

# Create a NSG that allows RDP 
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.resource_prefix}nsg-rdp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.azure_location

  security_rule {
    name                       = "allow-rdp-sr"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }
}

# Create NIC for DC VM
resource "azurerm_network_interface" "nic_dc" {
  name                = "${var.resource_prefix}nic-dc"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.azure_location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dc_public_ip.id
  }
}

# Link NSG to VNIC
resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.nic_dc.id
  network_security_group_id = azurerm_network_security_group.nsg.id

}

# Create VM for DC
resource "azurerm_windows_virtual_machine" "vm_dc" {
  name                = "${var.resource_prefix}vm-dc"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.azure_location
  size                = var.vm_size
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.nic_dc.id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"

  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"

  }
}

# Create NIC for Win11 VM
resource "azurerm_network_interface" "nic_w11" {
  name                = "${var.resource_prefix}nic-w11"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.azure_location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_internal.id
    private_ip_address_allocation = "Dynamic"

  }
}

# Create VM for Win11 VM
resource "azurerm_windows_virtual_machine" "vm_w11" {
  name                = "${var.resource_prefix}vm-w11"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.azure_location
  size                = var.vm_size
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.nic_w11.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"

  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-21h2-avd"
    version   = "latest"

  }
}

# Create NIC for Win10 VM
resource "azurerm_network_interface" "nic_w10" {
  name                = "${var.resource_prefix}nic-w10"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.azure_location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_internal.id
    private_ip_address_allocation = "Dynamic"

  }
}

# Create VM for Win10 VM
resource "azurerm_windows_virtual_machine" "vm_w10" {
  name                = "${var.resource_prefix}vm-w10"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.azure_location
  size                = var.vm_size
  admin_username      = var.username
  admin_password      = var.password
  network_interface_ids = [
    azurerm_network_interface.nic_w10.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"

  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-10"
    sku       = "win10-21h2-avd-g2"
    version   = "latest"

  }
}

# Bastion
# Create internal Subnet for Bastion
resource "azurerm_subnet" "subnet-bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/26"]
}

# Create Public IP for Bastion
resource "azurerm_public_ip" "bastion_public_ip" {
  name                = "${var.resource_prefix}pip-bastion"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.azure_location
  allocation_method   = "Static"
  sku                 = "Standard"
  
}

# Create Bastion host
resource "azurerm_bastion_host" "bastion" {
  name                 = "${var.resource_prefix}bastion"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = var.azure_location

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnet-bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }
}