data "azurerm_client_config" "current" {}

locals {
  podidentity_binding_name = "podidentity"
}

# Create the managed identity
resource "azurerm_user_assigned_identity" "podidentity" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = "id-${var.app_name}-pod"

}

# Create a namespace for pod identity
resource "kubernetes_namespace" "aad_pod_id_ns" {
  metadata {
    name = "podidentity"
  }
}

# Install Helm chart (Pod identity)
resource "helm_release" "aad_pod_id" {
  name       = "aad-pod-identity"
  repository = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
  chart      = "aad-pod-identity"
  namespace  = kubernetes_namespace.aad_pod_id_ns.metadata.0.name
  version    = var.helm_pod_identity_version
  values = [
    <<-EOF
    azureIdentities:
      "${azurerm_user_assigned_identity.podidentity.name}":
        resourceID: "${azurerm_user_assigned_identity.podidentity.id}"
        clientID: "${azurerm_user_assigned_identity.podidentity.client_id}"
        type: 0
        binding:
          name: "podidentity-binding"
          selector: "${local.podidentity_binding_name}"
    EOF
  ]
  depends_on = [
    azurerm_role_assignment.vm_contributor,
    azurerm_role_assignment.all_mi_operator,
    azurerm_role_assignment.mi_operator_podidentity
  ]
}

# Setup AKS Role Assignments for pod identity
data "azurerm_resource_group" "aks_node_rg" {
  name = azurerm_kubernetes_cluster.aks.node_resource_group
}

resource "azurerm_role_assignment" "vm_contributor" {
  scope                = data.azurerm_resource_group.aks_node_rg.id
  role_definition_name = "Virtual Machine Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

resource "azurerm_role_assignment" "all_mi_operator" {
  scope                = data.azurerm_resource_group.aks_node_rg.id
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
  role_definition_name = "Managed Identity Operator"
}

resource "azurerm_role_assignment" "mi_operator_podidentity" {
  scope                = azurerm_user_assigned_identity.podidentity.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
}

# Allow pod managed identity to access key vault
resource "azurerm_key_vault_access_policy" "kv_podidentity_access_policy" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.podidentity.principal_id
  key_permissions = [
    "get",
  ]
  secret_permissions = [
    "get",
  ]
  certificate_permissions = [
    "get",
  ]
  depends_on = [
    azurerm_role_assignment.mi_operator_podidentity
  ]
}

# Setup CSI Secrets Store for Azure Provider
resource "kubernetes_namespace" "app_ns" {
  metadata {
    name = var.app_name
  }
}

resource "helm_release" "csi-secrets-store-provider-azure" {
  name       = "csi-secrets-store-provider-azure"
  repository = "https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/charts"
  chart      = "csi-secrets-store-provider-azure"
  namespace  = kubernetes_namespace.app_ns.metadata.0.name
  version    = var.helm_csi_secrets_version
  set {
    name  = "secrets-store-csi-driver.linux.metricsAddr"
    value = ":8081"
  }
  # Use auto update of synced kubernetes secrets, see https://github.com/kubernetes-sigs/secrets-store-csi-driver/blob/master/docs/README.rotation.md#enable-auto-rotation
  set {
    name  = "secrets-store-csi-driver.enableSecretRotation"
    value = "true"
  }

  # The provider checks if it actually has access to the key vault
  depends_on = [azurerm_key_vault_access_policy.kv_podidentity_access_policy]
}

# Install KEDA on AKS cluster
resource "kubernetes_namespace" "keda_ns" {
  metadata {
    name = "keda"
  }
}

resource "helm_release" "keda" {
  name       = "keda"
  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  namespace  = kubernetes_namespace.keda_ns.metadata.0.name
  version    = var.helm_keda_version

  set {
    name  = "podIdentity.activeDirectory.identity"
    value = local.podidentity_binding_name
  }
}