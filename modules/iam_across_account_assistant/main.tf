terraform {
  required_version = "= 0.12.19"
}

module "iam_policies" {
  source                                         = "../iam_policies"
  should_require_mfa                             = var.should_require_mfa
  allow_read_only_access_from_other_account_arns = var.allow_read_only_access_from_other_account_arns
  allow_full_access_from_other_account_arns = var.allow_full_access_from_other_account_arns
  allow_billing_access_from_other_account_arns = var.allow_billing_access_from_other_account_arns
  across_account_access_role_arns_by_group       = var.across_account_access_role_arns_by_group
}

/*
Create an IAM group and attach a policy to it.
<policy_doc> is retrived from iam_policies module which defines a map of policy documents.
The key of the map is <policy_name> and the value of the map is a policy document.
*/

locals {
  groups_to_be_created = distinct(flatten([
    for name, user in var.iam_users: user.group_name_arr
  ]))
}


module "iam_groups" {
  source = "../iam_groups"

  across_account_groups = {
    for k, v in module.iam_policies.group_assume_policies_map :
    k => v.json
  }
  self_account_groups = {
    for group_name in local.groups_to_be_created :
    group_name => module.iam_policies.policy_map[group_name]
  }

  iam_users = var.iam_users
}

//Create roles according to the predefined Permissions policies for IAM roles
module "iam_roles" {
  source        = "../iam_roles"
  role_policies = module.iam_policies.role_policies_map
}


//Create organization and its related components such as organization account, unit ect.
//Only used for master account
locals {
  org_root_id_from_master_account = length(lookup(data.aws_organizations_organization.organization_data, "roots", [])) == 0 ? "" : data.aws_organizations_organization.organization_data.roots[0].id
  final_org_root_id               = var.create_organization ? aws_organizations_organization.org[0].roots[0].id : local.org_root_id_from_master_account
}

data "aws_organizations_organization" "organization_data" {}

resource "aws_organizations_organization" "org" {
  count = var.create_organization ? 1 : 0
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
  ]

  feature_set = "ALL"
}

resource "aws_organizations_organizational_unit" "second_layer_ous" {
  for_each  = var.second_layer_ous
  name      = each.key
  parent_id = local.final_org_root_id
}

resource "aws_organizations_organizational_unit" "third_layer_ous" {
  for_each  = var.third_layer_ous
  name      = each.key
  parent_id = length(lookup(aws_organizations_organizational_unit.second_layer_ous, each.value.parent_id, {})) == 0 ? each.value.parent_id : aws_organizations_organizational_unit.second_layer_ous[each.value.parent_id].id
}

resource "aws_organizations_organizational_unit" "fourth_layer_ous" {
  for_each  = var.fourth_layer_ous
  name      = each.key
  parent_id = length(lookup(aws_organizations_organizational_unit.third_layer_ous, each.value.parent_id, {})) == 0 ? each.value.parent_id : aws_organizations_organizational_unit.third_layer_ous[each.value.parent_id].id
}

resource "aws_organizations_account" "second_layer_accounts" {
  for_each = var.second_layer_child_accounts
  name     = each.key
  email    = each.value.email
}

resource "aws_organizations_account" "third_layer_accounts" {
  for_each  = var.third_layer_child_accounts
  name      = each.key
  email     = each.value.email
  parent_id = length(lookup(aws_organizations_organizational_unit.second_layer_ous, each.value.parent_id, {})) == 0 ? each.value.parent_id : aws_organizations_organizational_unit.second_layer_ous[each.value.parent_id].id
}

resource "aws_organizations_account" "fourth_layer_accounts" {
  for_each  = var.fourth_layer_child_accounts
  name      = each.key
  email     = each.value.email
  parent_id = length(lookup(aws_organizations_organizational_unit.third_layer_ous, each.value.parent_id, {})) == 0 ? each.value.parent_id : aws_organizations_organizational_unit.third_layer_ous[each.value.parent_id].id
}

resource "aws_organizations_account" "fifth_layer_accounts" {
  for_each  = var.fifth_layer_child_accounts
  name      = each.key
  email     = each.value.email
  parent_id = length(lookup(aws_organizations_organizational_unit.fourth_layer_ous, each.value.parent_id, {})) == 0 ? each.value.parent_id : aws_organizations_organizational_unit.fourth_layer_ous[each.value.parent_id].id
}