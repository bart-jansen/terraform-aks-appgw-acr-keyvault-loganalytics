# Create virtual network
resource "azurerm_virtual_network" "main" {
  name                = var.name
  address_space       = ["10.100.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}
