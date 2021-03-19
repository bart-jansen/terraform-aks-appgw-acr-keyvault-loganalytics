variable "resource_group" {
  type        = map(any)
  description = "Resource group"
}

variable "app_name" {
  type        = string
  description = "Application name. Use only lowercase letters and numbers"
}

variable "location" {
  type        = string
  description = "Azure region where to create resources."
}

variable "virtual_network_name" {
  type        = string
  description = "Virtual network name. This service will create subnets in this network."
}

variable "aks_config" {
  type        = map(any)
  description = "AKS Config Object"
}

variable "aks_object_id" {
  type        = string
  description = "AKS SP Object ID"
}

variable "domain_name_label" {
  type        = string
  description = "Domain name label for AKS Cluster / Application Gateway"
}

variable "helm_agic_version" {
  type        = string
  description = "Helm chart version of ingress-azure-helm-package"
}
