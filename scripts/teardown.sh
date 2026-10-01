#!/usr/bin/env bash
# Deletes EVERYTHING created for Task 10.3HD. Run once the video is recorded.
#
# Deleting the resource group (rather than terraform destroy) also removes the
# role assignments scoped to it, including your temporary User Access
# Administrator grant, which avoids the role-assignment destroy failure from
# Tasks 6.1P, 6.3D and 8.1P. The soft-deleted Key Vault is then purged so
# nothing is left recoverable or billing.
source "$(dirname "$0")/common.sh"

KV="$(tfout key_vault_name 2>/dev/null || echo jas220kvhd01)"
AKS="$(tfout aks_cluster_name 2>/dev/null || echo jas220akshd)"
read -r -p "Type DELETE to remove resource group ${RG} and everything in it: " ok
[ "${ok}" = "DELETE" ] || { echo "Cancelled."; exit 1; }

say "Deleting ${RG} (takes 5 to 10 minutes)"
az group delete --name "${RG}" --yes

say "Purging soft-deleted Key Vault ${KV}"
az keyvault purge --name "${KV}" --location "${LOCATION}" || echo "Vault already purged or not soft-deleted."

say "Removing local Terraform state and kube context"
rm -f "${TF_DIR}"/terraform.tfstate "${TF_DIR}"/terraform.tfstate.backup "${TF_DIR}"/tfplan
kubectl config delete-context "${AKS}" 2>/dev/null || true

say "Checks (both should be empty / false)"
az group exists --name "${RG}"
az keyvault list-deleted --query "[?name=='${KV}'].name" -o tsv
