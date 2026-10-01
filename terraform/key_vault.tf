# Key Vault is created EMPTY. The secret values are written afterwards by
# scripts/seed-secrets.sh using `az keyvault secret set`, so they never pass
# through Terraform and never land in terraform.tfstate. (The earlier design
# used azurerm_key_vault_secret resources, which store the value in state.)
#
# Authorisation uses Key Vault ACCESS POLICIES rather than Azure RBAC. Access
# policies are managed through Microsoft.KeyVault/vaults/write, which the
# CloudLabs Contributor role already has, so the vault needs no role
# assignments at all. This is the fallback approved in the Task 7.3HD
# proposal (risk 1), used here up front to remove an RBAC dependency.
resource "azurerm_key_vault" "kv" {
  name                       = var.key_vault_name
  location                   = data.azurerm_resource_group.rg.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  # Pinned explicitly. Newer Key Vault API versions default NEW vaults to
  # Azure RBAC, which would silently ignore the access policies below.
  rbac_authorization_enabled = false

  # The operator running Terraform (Jas) can manage secret values, so the
  # seed script can write them. This grants data-plane access only to the
  # person who already owns the vault.
  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
  }

  # The in-cluster workload identity can only READ secrets. A compromised pod
  # cannot change or delete anything in the vault.
  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = azurerm_user_assigned_identity.workload.principal_id
    secret_permissions = ["Get", "List"]
  }

  tags = var.tags
}
