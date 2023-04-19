output "cluster" {
  value = azurerm_kubernetes_cluster.kubernetes
  # Output is sensitive it might potentially print the AKS' Service Principal Credentials, if used
  sensitive = true
}

output "ingress_ip" {
  value = azurerm_public_ip.nginx_ingress[0].ip_address
}

output "cluster_egress_ip" {
  value = azurerm_public_ip.cluster_ip.ip_address
}
