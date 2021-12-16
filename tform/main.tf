terraform {
  required_version = ">=0.12"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  ## Enable below variables if a Service Principal is used
  # client_id       = var.client_id
  # client_secret   = var.client_secret
  # tenant_id       = var.tenant_id
}

## SHARED
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "dev" {
  name                = "${var.prefix}-dev-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "allow-ssh-in"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

## LOOP FOR EACH VM
resource "azurerm_public_ip" "pip" {
  for_each = {for vm in var.vm_defs: vm.name => vm}

  name                = "${var.prefix}-${each.key}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  domain_name_label   = "${var.prefix}-${each.key}-vm"
}

resource "azurerm_network_interface" "main" {
  for_each = {for vm in var.vm_defs: vm.name => vm}

  name                = "${var.prefix}-${each.key}-pub-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.key].id
  }
}

resource "azurerm_network_interface" "internal" {
  for_each = {for vm in var.vm_defs: vm.name => vm}

  name                = "${var.prefix}-${each.key}-priv-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  for_each = {for vm in var.vm_defs: vm.name => vm}

  network_interface_id      = azurerm_network_interface.main[each.key].id
  network_security_group_id = azurerm_network_security_group.dev.id
}

resource "azurerm_linux_virtual_machine" "main" {
  for_each = {for vm in var.vm_defs: vm.name => vm}

  name                            = "${var.prefix}-${each.key}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = each.value.size
  admin_username                  = "adminuser"
  disable_password_authentication = true
  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  network_interface_ids = [
    azurerm_network_interface.main[each.key].id,
    azurerm_network_interface.internal[each.key].id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = coalesce(each.value.image_offer, "UbuntuServer")
    sku       = coalesce(each.value.image_sku, "18_04-lts-gen2")
    version   = "latest"
  }

  os_disk {
    storage_account_type = each.value.os_storage_type
    disk_size_gb         = each.value.os_storage_size
    caching              = "ReadWrite"
  }

  timeouts {
    create = "90m"
    update = "90m"
    delete = "90m"
  }
}

resource "azurerm_managed_disk" "data" {
  for_each = {for vm in var.vm_defs: vm.name => vm}

  name                 = "${var.prefix}-${each.key}-data"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  create_option        = "Empty"
  disk_size_gb         = each.value.data_storage_size
  storage_account_type = each.value.data_storage_type
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  for_each = {for vm in var.vm_defs: vm.name => vm}

  virtual_machine_id = azurerm_linux_virtual_machine.main[each.key].id
  managed_disk_id    = azurerm_managed_disk.data[each.key].id
  lun                = 0
  caching            = "None"
}
