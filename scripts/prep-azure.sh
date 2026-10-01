#!/usr/bin/env bash
# Step 1 of 5. Creates the resource group and gives YOU User Access
# Administrator on it, so terraform apply can create the AcrPull and AcrPush
# role assignments in one go (the RBAC bootstrap problem from Weeks 6 to 10).
source "$(dirname "$0")/common.sh"

say "Azure account in use"
az account show --query "{subscription:name, user:user.name}" -o table

# CloudLabs sometimes blocks Microsoft Graph lookups, so the object id can be
# passed in instead: MY_OBJECT_ID=<id> bash scripts/prep-azure.sh
MY_OBJECT_ID="${MY_OBJECT_ID:-$(az ad signed-in-user show --query id -o tsv 2>/dev/null || true)}"
if [ -z "${MY_OBJECT_ID}" ]; then
  echo "Could not look up your object id. Re-run with MY_OBJECT_ID=<your object id>." >&2
  exit 1
fi
echo "Your object id: ${MY_OBJECT_ID}"

say "Creating resource group ${RG} in ${LOCATION}"
az group create --name "${RG}" --location "${LOCATION}" --tags Practical=Task10.3HD -o table

RG_ID="$(az group show --name "${RG}" --query id -o tsv)"

say "Granting you User Access Administrator on ${RG} only"
if az role assignment list --assignee "${MY_OBJECT_ID}" --scope "${RG_ID}" \
     --role "User Access Administrator" --query "[0].id" -o tsv | grep -q .; then
  echo "Already granted."
else
  az role assignment create \
    --assignee-object-id "${MY_OBJECT_ID}" \
    --assignee-principal-type User \
    --role "User Access Administrator" \
    --scope "${RG_ID}" -o table
fi

say "Your roles on ${RG}"
az role assignment list --assignee "${MY_OBJECT_ID}" --scope "${RG_ID}" --include-inherited \
  --query "[].roleDefinitionName" -o tsv

echo
echo "Done. Wait about 2 minutes for Azure AD to propagate the new role, then run terraform (see README)."
