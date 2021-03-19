# Create a resource group for this deployment
module "resource_group" {
  source = "./modules/resource_group"

  location = var.location
  name     = "rg-${var.app_name}"
}

# Create a common key vault to store application secrets
module "keyvault" {
  source = "./modules/key_vault"

  name                = "kv-${var.app_name}"
  location            = var.location
  resource_group_name = module.resource_group.name

  # Config
  enabled_for_deployment          = "true"
  enabled_for_disk_encryption     = "true"
  enabled_for_template_deployment = "true"
}

# Create the Azure Container Registry
module "acr" {
  source = "./modules/acr"

  name                = "acr${var.app_name}"
  resource_group_name = module.resource_group.name
  location            = var.location
}

# Key Vault Secrets - ACR username & password
module "kv_secret_docker_password" {
  source = "./modules/key_vault_secret"

  name         = "acr-docker-password"
  value        = module.acr.registry_password
  key_vault_id = module.keyvault.key_vault_id

  depends_on = [module.keyvault.azurerm_key_vault_access_policy]
}

module "kv_secret_docker_username" {
  source = "./modules/key_vault_secret"

  name         = "acr-docker-username"
  value        = module.acr.registry_username
  key_vault_id = module.keyvault.key_vault_id

  depends_on = [module.keyvault.azurerm_key_vault_access_policy]
}

# Create virtual network
module "vnet" {
  source = "./modules/vnet"

  name                = "vnet-${var.app_name}"
  resource_group_name = module.resource_group.name
  location            = var.location
}

# Create Log Analytics Insights #
module "log_analytics" {
  source = "./modules/log_analytics"

  app_name            = var.app_name
  resource_group_name = module.resource_group.name
  location            = var.location
}

# Create AKS Cluster
module "aks" {
  source = "./modules/aks"

  resource_group_name  = module.resource_group.name
  app_name             = var.app_name
  location             = var.location
  virtual_network_name = module.vnet.name

  acr_id           = module.acr.id
  key_vault_id     = module.keyvault.key_vault_id
  log_analytics_id = module.log_analytics.id

  ### AKS configuration params ###
  kubernetes_version  = var.kubernetes_version
  vm_size_node_pool   = var.vm_size_node_pool
  node_pool_min_count = var.node_pool_min_count
  node_pool_max_count = var.node_pool_max_count

  ### Helm Chart versions ###
  helm_pod_identity_version = var.helm_pod_identity_version
  helm_csi_secrets_version  = var.helm_csi_secrets_version
}


# Create Application Gateway
module "appgw" {
  source = "./modules/appgw"

  resource_group       = { "name" : module.resource_group.name, "id" : module.resource_group.id }
  app_name             = var.app_name
  location             = var.location
  virtual_network_name = module.vnet.name
  aks_object_id        = module.aks.kubelet_identity
  aks_config           = module.aks.aks_config
  domain_name_label    = var.domain_name_label

  ### Helm Chart versions ###
  helm_agic_version = var.helm_agic_version
}

