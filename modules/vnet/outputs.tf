output "name" {
  value = azurerm_virtual_network.main.name
}

output "id" {
  value     = azurerm_virtual_network.main.id
  sensitive = true
}