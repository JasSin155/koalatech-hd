# The resource group is created by scripts/prep-azure.sh, NOT by Terraform.
#
# This is the fix for the RBAC bootstrap problem hit three times in this unit:
# the CloudLabs account cannot hold User Access Administrator on a resource
# group that does not exist yet, and Terraform needs that role to create the
# two role assignments below (AcrPull and AcrPush). Creating the group first,
# granting the role on it, then letting Terraform read it as a data source
# means a single terraform apply succeeds first time.
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}
