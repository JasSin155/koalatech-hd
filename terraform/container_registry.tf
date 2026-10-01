resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "Basic"

  # Admin user OFF (it was on in Weeks 6 to 9). Nothing needs a shared
  # username and password any more: AKS pulls with its kubelet identity and
  # GitHub Actions pushes with a federated identity.
  admin_enabled = false

  tags = var.tags
}

# AKS kubelet identity -> pull images.
resource "azurerm_role_assignment" "acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

# GitHub Actions identity -> push images. This is the ONLY Azure permission
# the CI pipeline has. It cannot read Key Vault and cannot reach the cluster.
resource "azurerm_role_assignment" "acr_push" {
  principal_id                     = azurerm_user_assigned_identity.github_actions.principal_id
  role_definition_name             = "AcrPush"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
