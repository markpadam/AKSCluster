terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      //version = "=2.46.0"
      version = "=2.89.0" //Required to run locally on M1 MAC OS
    }
  }
}

provider "azurerm" {
  features {}
	  subscription_id = var.subscription_id
}

//Create resource group
resource "azurerm_resource_group" "RG" {
	name = "rg-k8s-core"
	location = var.location
	tags = {
    ownername = "MarkAdam" //Require for deployment into dev enviroment due to policy
  }
}

//Create the AKS Cluster
resource "azurerm_kubernetes_cluster" "k8s" {
	
  name                = var.cluster_name
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  node_resource_group = "rg-k8s-nodes"
  dns_prefix          = var.dns_prefix

default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
    vnet_subnet_id = azurerm_subnet.SN-Nodes.id
  }

  identity {
    type = "SystemAssigned"
  }

tags = {
    ownername = "MarkAdam" //Require for deployment into dev enviroment due to policy
  }
}

//Create Virtual Network
resource "azurerm_virtual_network" "VNET" {
  name                = "vnet-aks-onetrust"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  address_space       = ["10.10.10.0/24"]
  dns_servers         = []

tags = {
    ownername = "MarkAdam" //Require for deployment into dev enviroment due to policy
  }
}

//Virtual Network Subnets
resource "azurerm_subnet" "SN-Nodes" {
  name                 = "AKS"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.VNET.name
  address_prefixes     = ["10.10.10.0/25"]
}
resource "azurerm_subnet" "MGMT" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.VNET.name
  address_prefixes     = ["10.10.10.128/25"]
}

//OneTrust Management VM
resource "azurerm_network_interface" "NIC" {
  name                = "nic1"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.MGMT.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_virtual_machine" "VM" {
  name                  = "vm-onetrustmgmt"
  location              = azurerm_resource_group.RG.location
  resource_group_name   = azurerm_resource_group.RG.name
  network_interface_ids = [azurerm_network_interface.NIC.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "ubuntumgmt"
    admin_username = var.linuxuser
    admin_password = var.linuxpassword
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
tags = {
    ownername = "MarkAdam" //Require for deployment into dev enviroment due to policy
  }
}

# resource "azurerm_virtual_machine_extension" "BOOTSTRAP" {
#   name                 = "cloudinit"
#   virtual_machine_id   = azurerm_virtual_machine.VM.id
#   publisher            = "Microsoft.Azure.Extensions"
#   type                 = "CustomScript"
#   type_handler_version = "2.0"

#   settings = <<SETTINGS
#     {
#         "commandToExecute": "sudo apt update && sudo apt install docker -y && sudo apt install kubectl -y && sudo apt install azure-cli -y"
#     }
# SETTINGS
# }