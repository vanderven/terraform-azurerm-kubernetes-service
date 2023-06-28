resource "azurerm_role_assignment" "acr" {
  count                            = var.acr_id != null ? 1 : 0
  principal_id                     = azurerm_kubernetes_cluster.kubernetes.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "k8s_vnet_access" {
  count                = var.ingress_controller == true ? 1 : 0
  scope                = var.aks_vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.kubernetes.kubelet_identity[0].object_id
}
