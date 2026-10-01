resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = var.aks_dns_prefix

  # null = let AKS pick its current default GA version, so this module does
  # not break when CloudLabs retires a pinned minor version.
  kubernetes_version = var.kubernetes_version

  automatic_upgrade_channel = "patch"

  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = var.aks_node_vm_size
    max_pods   = 50

    # Declared explicitly to match the defaults Azure applies at creation.
    # Without this block every later plan shows drift and tries to null them,
    # which would trigger a needless node pool update on the live cluster.
    upgrade_settings {
      max_surge                     = "10%"
      drain_timeout_in_minutes      = 0
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type = "SystemAssigned"
  }

  # Workload Identity: the cluster becomes an OIDC token issuer, and the
  # mutating webhook projects a signed ServiceAccount token into any pod
  # labelled azure.workload.identity/use=true.
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # Secrets Store CSI driver + Azure Key Vault provider, managed by Terraform
  # (the earlier design wrongly assumed this needed a manual
  # `az aks enable-addons` step).
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  tags = var.tags
}
