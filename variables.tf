### General ###
variable "app_name" {
  type        = string
  description = "Application name. Use only lowercase letters and numbers"
}

variable "location" {
  type        = string
  description = "Azure region where to create resources."
  default     = "West Europe"
}

variable "domain_name_label" {
  type        = string
  description = "Unique domain name label for AKS Cluster / Application Gateway"
  default     = "aks-cluster-test"
}


### AKS configuration params ###
variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version of the node pool"
  default     = "1.21.7"
}

variable "vm_size_node_pool" {
  type        = string
  description = "VM Size of the node pool"
  default     = "Standard_D2s_v3"
}

variable "node_pool_min_count" {
  type        = string
  description = "VM minimum amount of nodes for the node pool"
  default     = 3
}

variable "node_pool_max_count" {
  type        = string
  description = "VM maximum amount of nodes for the node pool"
  default     = 5
}


### Helm Chart versions ###
variable "helm_pod_identity_version" {
  type        = string
  description = "Helm chart version of aad-pod-identity"
  default     = "4.1.1"
}

variable "helm_csi_secrets_version" {
  type        = string
  description = "Helm chart version of secrets-store-csi-driver-provider-azure"
  default     = "0.0.18"
}

variable "helm_agic_version" {
  type        = string
  description = "Helm chart version of ingress-azure-helm-package"
  default     = "1.4.0"
}

variable "helm_keda_version" {
  type        = string
  description = "Helm chart version of keda helm package"
  default     = "2.3.2"
}
