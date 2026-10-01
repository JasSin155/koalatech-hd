variable "resource_group_name" {
  description = "Existing resource group created by scripts/prep-azure.sh"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for identity names"
  type        = string
  default     = "koalatech-hd"
}

variable "acr_name" {
  type = string
}

variable "aks_cluster_name" {
  type = string
}

variable "aks_dns_prefix" {
  type = string
}

variable "aks_node_count" {
  type    = number
  default = 2
}

variable "aks_node_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "kubernetes_version" {
  description = "null lets AKS choose its current default version"
  type        = string
  default     = null
}

variable "key_vault_name" {
  description = "Globally unique, 3 to 24 characters"
  type        = string
}

variable "storage_account_name" {
  type = string
}

variable "app_namespace" {
  description = "Namespace the KoalaTech workloads run in (must match the GitOps manifests)"
  type        = string
  default     = "production"
}

variable "app_service_account" {
  description = "ServiceAccount the KoalaTech pods use (must match the GitOps manifests)"
  type        = string
  default     = "koalatech-sa"
}

variable "github_owner" {
  type    = string
  default = "JasSin155"
}

variable "github_repo_name" {
  description = "App repository whose main branch may push images"
  type        = string
  default     = "koalatech-hd"
}

variable "tags" {
  type = map(string)
  default = {
    Project   = "KoalaTech Course Platform"
    ManagedBy = "Terraform"
    Practical = "Task10.3HD"
  }
}
