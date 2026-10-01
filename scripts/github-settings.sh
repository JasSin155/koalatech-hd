#!/usr/bin/env bash
# Step 4b. Prints the GitHub repository VARIABLES for koalatech-hd.
# None of these are secrets (they are identifiers), which is the point:
# the Azure login in CI is federated, there is no client secret to store.
source "$(dirname "$0")/common.sh"

cat <<OUT

Add these under koalatech-hd > Settings > Secrets and variables > Actions > Variables tab:

  AZURE_CLIENT_ID        $(tfout github_actions_client_id)
  AZURE_TENANT_ID        $(tfout tenant_id)
  AZURE_SUBSCRIPTION_ID  $(tfout subscription_id)
  ACR_LOGIN_SERVER       $(tfout acr_login_server)

And these three under the Secrets tab (values from your Notepad, not from here):

  DOCKERHUB_USERNAME
  DOCKERHUB_TOKEN
  GITOPS_TOKEN
OUT
