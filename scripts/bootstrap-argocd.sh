#!/usr/bin/env bash
# Step 5 of 5. Connects kubectl, checks the Key Vault CSI driver add-on is
# running (Terraform enabled it), installs Argo CD, and registers the one
# Application that points the cluster at the koalatech-gitops repository.
# After this, nothing in this repo ever runs kubectl apply again.
source "$(dirname "$0")/common.sh"

AKS="$(tfout aks_cluster_name)"
say "Getting credentials for ${AKS}"
az aks get-credentials -g "${RG}" -n "${AKS}" --overwrite-existing
kubectl get nodes -o wide

say "Secrets Store CSI driver pods (from the Terraform-managed add-on)"
kubectl get pods -n kube-system -l 'app in (secrets-store-csi-driver,secrets-store-provider-azure)'

say "Installing Argo CD ${ARGOCD_VERSION}"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
# --server-side is required: the Argo CD CRDs are too large for the
# last-applied annotation that client-side apply writes.
kubectl apply -n argocd --server-side --force-conflicts \
  -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"
kubectl -n argocd rollout status deploy/argocd-server --timeout=300s
kubectl -n argocd rollout status deploy/argocd-repo-server --timeout=300s
kubectl -n argocd rollout status statefulset/argocd-application-controller --timeout=300s

say "Registering the koalatech-production Application"
kubectl apply -f "${GITOPS_DIR}/argocd/koalatech-production.yaml"

cat <<OUT

Argo CD is installed. To open the UI:
  kubectl -n argocd port-forward svc/argocd-server 8080:443
  then browse to https://localhost:8080 (accept the self-signed cert), user: admin
  password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

Watch the rollout:
  kubectl get application -n argocd koalatech-production -w
  kubectl get pods -n production -w
OUT
