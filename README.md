# Terraform - Azure Kubernetes Service deployment

Setting up an Azure Kubernetes Service (AKS) using terraform, is fairly easy. Setting up a full-fledged AKS cluster that can read images from Azure Container Registry (ACR), fetch secrets from Azure Key Vault using Pod Identity while all traffic is routed via an AKS managed Application Gateway is much harder.

This repository serves as a boilerplate for the scenario described above, and fully deploys and configures your Azure Kubernetes Service in the cloud using a single terraform command.

## Input Variables

| Name | Description | Default |
|------|-------------|---------|
| `app_name` | Application name (used as suffix in all resources) |  | 
| `location` | Azure region where to create resources | West Europe | 
| `domain_name_label` | Unique domain name label for AKS Cluster |  | 
| `kubernetes_version` | Kubernetes version of the node pool | 1.19.7 | 
| `vm_size_node_pool` | VM Size of the node pool | Standard_D2s_v3 | 
| `node_pool_min_count` | VM minimum amount of nodes for the node pool | 3 | 
| `node_pool_max_count` | VM maximum amount of nodes for the node pool | 5 | 
| `helm_pod_identity_version` | Helm chart version of aad-pod-identity | 3.0.3 | 
| `helm_csi_secrets_version` | Helm chart version of secrets-store-csi-driver-provider-azure | 0.0.17 | 
| `helm_agic_version` | Helm chart version of ingress-azure-helm-package | 1.4.0 | 


## Output variables

| Name | Description |
|------|-------------|
| `aks_name` | Name of the AKS cluster |
| `appgw_name` | Name of the Application Gateway used by AKS |
| `appgw_fqdn` | Domain name of the cluster (e.g. `label.westeurope.cloudapp.azure.com`) |
| `acr_name` | Name of the Azure Container Registry |
| `keyvault_name` | Name of the Azure Key Vault |
| `log_analytics_name` | Name of the Log Analytics workspace |
| `vnet_name` | Name of the Virtual Network |
| `rg_name` | Name of the Resource Group |