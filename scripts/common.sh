#!/usr/bin/env bash
# Shared settings, sourced by every script. Run scripts from the repo root:
#   bash scripts/<name>.sh
set -euo pipefail
# Git Bash on Windows rewrites arguments that start with / into Windows paths,
# which breaks --scope /subscriptions/... and kubectl exec paths. Turn that off.
export MSYS_NO_PATHCONV=1
# `pwd -W` (Git Bash only) gives C:/Users/... which Windows programs such as
# terraform.exe and kubectl.exe understand even with path conversion off.
# On Linux/macOS it fails and plain `pwd` is used instead.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && { pwd -W 2>/dev/null || pwd; })"
TF_DIR="${REPO_ROOT}/terraform"
GITOPS_DIR="${GITOPS_DIR:-${REPO_ROOT}/../koalatech-gitops}"
RG="${RG:-koalatech-hd-rg}"
LOCATION="${LOCATION:-australiaeast}"
ARGOCD_VERSION="${ARGOCD_VERSION:-v3.5.3}"
tfout() { terraform -chdir="${TF_DIR}" output -raw "$1"; }
say()   { printf '\n==> %s\n' "$*"; }
