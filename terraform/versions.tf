# Task 10.3HD infrastructure.
#
# State is deliberately LOCAL for this module. It is run by hand from Jas's
# own terminal (not from CI), because the pipeline no longer needs cluster or
# Terraform access at all in the GitOps model: CI only builds, scans, pushes
# images and commits a new image tag to the GitOps repo. Argo CD does the rest.
#
# No application secret passes through this module. Key Vault is created
# empty and scripts/seed-secrets.sh writes the secret values straight into it,
# so they never appear in a .tfvars file, a Terraform variable, or this state.
terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      # Teardown should leave nothing behind, including the soft-deleted vault
      # that would otherwise block reusing the same vault name.
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "azurerm_client_config" "current" {}
