resource "azurerm_resource_group" "rg" {
    name = var.rg_name 
    location = var.rg_location
}

resource "azurerm_virtual_network" "vnet" {
    name = var.vnet_name 
    resource_group_name = azurerm_resource_group.rg.name 
    location = azurerm_resource_group.rg.location
    address_space = var.address_space
}