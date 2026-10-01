#!/usr/bin/env bash
# Demo helper for the video (proposal success criterion 2).
# Fetches the REAL postgres password from Key Vault into a shell variable
# (never printed), then proves it does not exist in: either Git repository's
# full history, the Terraform state file, or any Kubernetes Secret object.
source "$(dirname "$0")/common.sh"

KV="$(tfout key_vault_name)"
PW="$(az keyvault secret show --vault-name "${KV}" --name postgres-password --query value -o tsv)"
echo "Fetched postgres-password from ${KV} (${#PW} characters, value not shown)"

count_in() { grep -F -c -- "${PW}" || true; }

say "1. App repo, every commit on every branch"
echo "   matches: $(git -C "${REPO_ROOT}" log --all -p | count_in)"
say "2. GitOps repo, every commit on every branch"
echo "   matches: $(git -C "${GITOPS_DIR}" log --all -p | count_in)"
say "3. terraform.tfstate"
echo "   matches: $(count_in < "${TF_DIR}/terraform.tfstate")"
say "4. Kubernetes Secret objects in the production namespace"
kubectl get secrets -n production --no-headers 2>/dev/null | wc -l | xargs -I{} echo "   Secret objects: {}"
say "5. But the running pod DOES have it, mounted from Key Vault"
POD="$(kubectl get pod -n production -l app=user-service -o jsonpath='{.items[0].metadata.name}')"
kubectl exec -n production "${POD}" -- ls -l /mnt/secrets-store
MATCH="$(kubectl exec -n production "${POD}" -- cat /mnt/secrets-store/postgres-password | count_in)"
echo "   pod file matches Key Vault value: $([ "${MATCH}" = 1 ] && echo yes || echo no)"
unset PW
