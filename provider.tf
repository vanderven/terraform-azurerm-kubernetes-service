terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "<4.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "<3.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "<3.0.0"
    }
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.kubernetes.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.kubernetes.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.kubernetes.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.kubernetes.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.kubernetes.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.kubernetes.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.kubernetes.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.kubernetes.kube_config.0.cluster_ca_certificate)
  }
}
