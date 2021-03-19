output "name" {
  value = azurerm_container_registry.acr.name
}

output "id" {
  value = azurerm_container_registry.acr.id
}

output "registry_password" {
  description = "The Password associated with the Container Registry Admin account"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

output "registry_username" {
  description = "The Username associated with the Container Registry Admin account"
  value       = azurerm_container_registry.acr.admin_username
  sensitive   = true
}