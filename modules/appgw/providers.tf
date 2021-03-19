provider "kubernetes" {
  host                   = var.aks_config.host
  client_certificate     = base64decode(var.aks_config.client_certificate)
  client_key             = base64decode(var.aks_config.client_key)
  cluster_ca_certificate = base64decode(var.aks_config.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = var.aks_config.host
    client_certificate     = base64decode(var.aks_config.client_certificate)
    client_key             = base64decode(var.aks_config.client_key)
    cluster_ca_certificate = base64decode(var.aks_config.cluster_ca_certificate)
  }
}