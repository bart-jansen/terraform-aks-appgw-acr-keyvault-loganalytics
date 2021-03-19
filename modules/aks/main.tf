# Subnet
resource "azurerm_subnet" "aks_subnet" {
  name                 = "snet-${var.app_name}-aks"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["10.100.1.0/24"]
}

# Subnet permission
resource "azurerm_role_assignment" "aks_subnet_rbac" {
  scope                = azurerm_subnet.aks_subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

# Allow the AKS to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull_role" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

# Kubernetes Service
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.app_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks-${var.app_name}"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    type                = "VirtualMachineScaleSets"
    name                = "default"
    node_count          = var.node_pool_min_count
    vm_size             = var.vm_size_node_pool
    os_disk_size_gb     = 30
    vnet_subnet_id      = azurerm_subnet.aks_subnet.id
    enable_auto_scaling = true
    max_count           = var.node_pool_max_count
    min_count           = var.node_pool_min_count
  }

  network_profile {
    network_plugin = "azure"
  }


  addon_profile {
    aci_connector_linux { enabled = false }
    azure_policy { enabled = false }
    http_application_routing { enabled = false }
    kube_dashboard { enabled = false }
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.log_analytics_id
    }
  }

  role_based_access_control {
    enabled = true
  }

  identity {
    type = "SystemAssigned"
  }
}