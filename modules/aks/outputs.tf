output "kubelet_identity" {
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
  description = "The kubelet identity."
}

output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
  description = "Name of the AKS cluster"
}

output "aks_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0
  sensitive =  true
  description = "AKS Config object"
}