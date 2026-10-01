# Profile photo storage, unchanged in purpose from Weeks 6 to 10.
#
# Known limitation, stated rather than hidden: Azure generates this account's
# access keys, and the azurerm provider records them as attributes of the
# storage account in terraform.tfstate. The seed script copies the connection
# string into Key Vault so the pods read it from there, but the key itself
# still exists in local state, which is why state is kept local, gitignored,
# and deleted at teardown.
resource "azurerm_storage_account" "storage" {
  name                            = var.storage_account_name
  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = data.azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_0"
  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true
  shared_access_key_enabled       = true # needed by the current app (connection string)

  # Fixed after the first checkov run (CKV2_AZURE_38): deleted blobs and
  # containers are recoverable for 7 days.
  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  # Fixed after the first checkov run (CKV2_AZURE_41): the app issues its own
  # short-lived SAS URLs, this policy flags any SAS longer than one day.
  sas_policy {
    expiration_period = "01.00:00:00"
  }

  tags = var.tags
}

resource "azurerm_storage_container" "student_photos" {
  name                  = "student-profile-photos"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "lecturer_photos" {
  name                  = "lecturer-profile-photos"
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}
