#!/usr/bin/env bash
# Step 4a. Fills the four NON-secret identifiers from terraform output into
# the koalatech-gitops working copy (client id, vault name, tenant id, ACR).
# Refuses to finish if any __PLACEHOLDER__ is left behind (risk 7 in the
# original risk register).
source "$(dirname "$0")/common.sh"

[ -d "${GITOPS_DIR}/manifests" ] || { echo "GitOps repo not found at ${GITOPS_DIR}" >&2; exit 1; }

WL_CLIENT_ID="$(tfout workload_identity_client_id)"
KV="$(tfout key_vault_name)"
TENANT="$(tfout tenant_id)"
ACR="$(tfout acr_login_server)"

say "Rendering ${GITOPS_DIR}/manifests"
for f in "${GITOPS_DIR}"/manifests/*.yaml; do
  sed -i \
    -e "s|__WORKLOAD_CLIENT_ID__|${WL_CLIENT_ID}|g" \
    -e "s|__KEY_VAULT_NAME__|${KV}|g" \
    -e "s|__TENANT_ID__|${TENANT}|g" \
    -e "s|__ACR_LOGIN_SERVER__|${ACR}|g" \
    "$f"
done

if grep -rn "__[A-Z_]*__" "${GITOPS_DIR}/manifests"; then
  echo "Placeholders left above, fix before committing." >&2
  exit 1
fi
echo "All placeholders filled. Review with: git -C \"${GITOPS_DIR}\" diff"
