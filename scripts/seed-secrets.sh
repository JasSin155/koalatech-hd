#!/usr/bin/env bash
# Step 3 of 5. Writes the application secrets STRAIGHT into Key Vault.
#
# Values are generated here with openssl and sent to Key Vault with the Azure
# CLI. They are never printed, never written to a file, and never passed to
# Terraform, so they cannot appear in Git or in terraform.tfstate.
#
# Idempotent: a secret that already exists is left alone. This matters because
# postgres fixes its password on first start, so rotating it silently would
# lock the services out of their own databases.
source "$(dirname "$0")/common.sh"

KV="$(tfout key_vault_name)"
SA="$(tfout storage_account_name)"
say "Seeding Key Vault ${KV}"

put_if_missing() {
  local name="$1" value="$2"
  if az keyvault secret show --vault-name "${KV}" --name "${name}" --query id -o tsv >/dev/null 2>&1; then
    echo "  ${name}: already present, left unchanged"
  else
    az keyvault secret set --vault-name "${KV}" --name "${name}" --value "${value}" --output none
    echo "  ${name}: created"
  fi
}

# Hex only, so the values are safe inside the SQLAlchemy connection URL the
# services build from POSTGRES_USER and POSTGRES_PASSWORD.
put_if_missing postgres-user          "koalatech"
put_if_missing postgres-password      "$(openssl rand -hex 24)"
put_if_missing jwt-secret-key         "$(openssl rand -hex 32)"
put_if_missing default-admin-password "$(openssl rand -hex 12)"
put_if_missing storage-connection-string \
  "$(az storage account show-connection-string -g "${RG}" -n "${SA}" --query connectionString -o tsv)"

say "Secrets now in ${KV} (names only)"
az keyvault secret list --vault-name "${KV}" --query "[].name" -o tsv
echo
echo "To log in to the app as admin later, read the password with:"
echo "  az keyvault secret show --vault-name ${KV} --name default-admin-password --query value -o tsv"
