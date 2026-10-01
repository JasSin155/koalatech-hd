output "resource_group_name" {
  value = data.azurerm_resource_group.rg.name
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aks_oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

output "key_vault_name" {
  value = azurerm_key_vault.kv.name
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "workload_identity_client_id" {
  value = azurerm_user_assigned_identity.workload.client_id
}

output "github_actions_client_id" {
  value = azurerm_user_assigned_identity.github_actions.client_id
}
