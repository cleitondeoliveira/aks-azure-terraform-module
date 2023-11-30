output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.this.id
}

output "aks_cluster_kube_config" {
  value     = azurerm_kubernetes_cluster.this.kube_config
  sensitive = true
}

output "aks_cluster_kube_config_raw" {
  value     = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive = true
}

output "aks_cluster_private_fqdn" {
  value = azurerm_kubernetes_cluster.this.private_fqdn
}