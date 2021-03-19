# Subscription ID is required for AGIC
data "azurerm_subscription" "current" {}

# Subnet
resource "azurerm_subnet" "appgw" {
  name                 = "snet-${var.app_name}_appgw"
  resource_group_name  = var.resource_group.name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["10.100.2.0/24"]
}

# Create managed identity for application gateway
resource "azurerm_user_assigned_identity" "agidentity" {
  resource_group_name = var.resource_group.name
  location            = var.location
  name                = "id_${var.app_name}_appgw"
}

#
# Ingress controller
#
# The ingress controller requires the following permissions:
# - Reader on the resource group
# - Contributor on the App gateway
# - Managed Identity Operator on the user created identity
#

resource "azurerm_role_assignment" "appgwreader" {
  scope                = var.resource_group.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.agidentity.principal_id
}

resource "azurerm_role_assignment" "mi_operator_ag" {
  scope                = var.resource_group.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.agidentity.principal_id
}

resource "azurerm_role_assignment" "agic_contrib" {
  scope                = azurerm_application_gateway.appgateway.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.agidentity.principal_id
}

resource "azurerm_role_assignment" "mi_operator_agic" {
  scope                = azurerm_user_assigned_identity.agidentity.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.aks_object_id
}


# Application Gateway
locals {
  backend_address_pool_name      = "${var.virtual_network_name}-beap"
  frontend_port_name             = "${var.virtual_network_name}-feport"
  frontend_ip_configuration_name = "${var.virtual_network_name}-feip"
  http_setting_name              = "${var.virtual_network_name}-be-htst"
  http_listener_name             = "${var.virtual_network_name}-httplstn"
  request_routing_rule_name      = "${var.virtual_network_name}-rqrt"
}

# Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "pip-${var.app_name}-aks"
  resource_group_name = var.resource_group.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.domain_name_label # Maps to <domain_name_label>.<region>.cloudapp.azure.com
}

# Application gateway
resource "azurerm_application_gateway" "appgateway" {
  name                = "appgw-${var.app_name}-aks"
  resource_group_name = var.resource_group.name
  location            = var.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.http_listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.http_listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.agidentity.id]
  }

  lifecycle {
    ignore_changes = [
      tags,
      backend_address_pool,
      backend_http_settings,
      probe,
      identity,
      request_routing_rule,
      url_path_map,
      frontend_port,
      http_listener,
      redirect_configuration
    ]
  }
}

# Install helm package for application gateway
resource "helm_release" "agic" {
  name       = "agic"
  repository = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package"
  chart      = "ingress-azure"
  namespace  = var.app_name # todo: pass proper name from aks module
  version    = var.helm_agic_version
  timeout    = 600

  set {
    name  = "appgw.subscriptionId"
    value = data.azurerm_subscription.current.subscription_id
  }

  set {
    name  = "appgw.resourceGroup"
    value = var.resource_group.name
  }

  set {
    name  = "appgw.name"
    value = azurerm_application_gateway.appgateway.name
  }

  set {
    name  = "armAuth.identityResourceID"
    value = azurerm_user_assigned_identity.agidentity.id
  }

  set {
    name  = "armAuth.identityClientID"
    value = azurerm_user_assigned_identity.agidentity.client_id
  }

  set {
    name  = "armAuth.type"
    value = "aadPodIdentity"
  }

  set {
    name  = "appgw.shared"
    value = false
  }

  set {
    name  = "appgw.usePrivateIP"
    value = false
  }

  set {
    name  = "rbac.enabled"
    value = true
  }

  set {
    name  = "verbosityLevel"
    value = 3
  }

  depends_on = [
    azurerm_application_gateway.appgateway,
    azurerm_role_assignment.appgwreader,
    azurerm_role_assignment.mi_operator_ag,
    azurerm_role_assignment.agic_contrib,
    azurerm_role_assignment.mi_operator_agic
  ]
}