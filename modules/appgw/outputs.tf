output "appgw_fqdn" {
  value       = azurerm_public_ip.public_ip.fqdn
  description = "FQDN of the Application Gateway / AKS Cluster."
}

output "appgw_name" {
  value       = azurerm_application_gateway.appgateway.name
  description = "Name of the Application Gateway used by AKS"
}