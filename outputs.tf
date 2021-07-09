
output "aks_name" {
  value       = module.aks.aks_name
  description = "Name of the AKS cluster"
}

output "appgw_name" {
  value       = module.appgw.appgw_name
  description = "Name of the Application Gateway used by AKS"
}

output "appgw_fqdn" {
  value       = module.appgw.appgw_fqdn
  description = "FQDN of the Application Gateway"
}

output "acr_name" {
  value       = module.acr.name
  description = "Name of the Azure Container Registry"
}

output "keyvault_name" {
  value       = module.keyvault.key_vault_name
  sensitive   = true
  description = "Name of the Azure Key Vault"
}

output "log_analytics_name" {
  value       = module.log_analytics.name
  description = "Name of the Log Analytics workspace"
}

output "vnet_name" {
  value       = module.vnet.name
  description = "Name of the Virtual Network"
}

output "rg_name" {
  value       = module.resource_group.name
  description = "Name of the Resource Group"
}

output "rg_location" {
  value       = module.resource_group.location
  description = "Location of the Resource Group"
}

