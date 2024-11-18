resource "azurerm_resource_group" "myrg" {
   name     = var.rg_name
   location = var.rg_location
}

resource "azurerm_virtual_network" "myvnet" {
   name                 = var.vnet_name
   resource_group_name  = azurerm_resource_group.myrg.name
   location             = azurerm_resource_group.myrg.location
   address_space        = var.address_space
}

resource "azurerm_subnet" "subnet" {
    name                    = var.subnet_name
    resource_group_name     = azurerm_resource_group.myrg.name
    virtual_network_name    = azurerm_virtual_network.myvnet.name
    address_prefixes        = ["10.10.0.0/24"] 
}

resource "azurerm_public_ip" "mypip" {
  name                = var.pip
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "mynic" {
  name                = "my-nic-1"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  ip_configuration {
    name                          = "my-ip-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mypip.id
  }
}

resource "azurerm_linux_virtual_machine" "myvm" {
  name                  = "my-vm-1"
  location              = azurerm_resource_group.myrg.location
  resource_group_name   = azurerm_resource_group.myrg.name
  size                  = "Standard_B1s"
  admin_username        = "adminuser"

  network_interface_ids = [azurerm_network_interface.mynic.id]

  admin_ssh_key {
    username   = "adminuser"
    # ssh-keygen -t rsa -f C:\Terraform\SSHKeys\id_rsa  <-- command to generate keys in windows
    public_key = file("C:/Terraform/T20/Terraform/SSH_Keys/id_rsa.pub") 
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

    source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

