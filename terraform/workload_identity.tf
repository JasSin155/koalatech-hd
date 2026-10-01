# ---------------------------------------------------------------------------
# 1. Identity used INSIDE the cluster by the KoalaTech pods to read Key Vault.
# ---------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "workload" {
  name                = "${var.name_prefix}-workload-id"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = var.tags
}

# Trust relationship: Azure AD accepts a token issued by THIS cluster's OIDC
# issuer, for THIS exact ServiceAccount, in exchange for an access token for
# the identity above. Any other namespace or ServiceAccount name gets nothing.
resource "azurerm_federated_identity_credential" "workload" {
  name      = "koalatech-k8s-sa"
  parent_id = azurerm_user_assigned_identity.workload.id
  audience  = ["api://AzureADTokenExchange"]
  issuer    = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject   = "system:serviceaccount:${var.app_namespace}:${var.app_service_account}"
}

# ---------------------------------------------------------------------------
# 2. Identity used by GitHub Actions to push images (replaces the long-lived
#    AZURE_CREDENTIALS client secret used in Weeks 7 to 10).
# ---------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "github_actions" {
  name                = "${var.name_prefix}-github-id"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = var.tags
}

# Only a workflow running on the main branch of this exact repository can
# exchange its GitHub OIDC token for this identity. Pull requests never get
# Azure access, they only build and scan.
resource "azurerm_federated_identity_credential" "github_main" {
  name      = "github-${var.github_repo_name}-main"
  parent_id = azurerm_user_assigned_identity.github_actions.id
  audience  = ["api://AzureADTokenExchange"]
  issuer    = "https://token.actions.githubusercontent.com"
  subject   = "repo:${var.github_owner}/${var.github_repo_name}:ref:refs/heads/main"
}
