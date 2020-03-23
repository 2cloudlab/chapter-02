terraform {
  required_version = "= 0.12.19"
}

locals {
  self_account_groups = {
    full_access = {
      iam_policy     = module.iam_policies.policy_map["AdministratorAccess"]
    }
    billing = {
      iam_policy     = module.iam_policies.policy_map["Billing"]
    }
  }
}


module "iam_policies" {
  source                                         = "../iam_policies"
  should_require_mfa                             = var.should_require_mfa
  allow_read_only_access_from_other_account_arns = var.allow_read_only_access_from_other_account_arns
  across_account_access_role_arns_by_group       = var.across_account_access_role_arns_by_group
}

/*
Create an IAM group and attach a policy to it.
<policy_doc> is retrived from iam_policies module which defines a map of policy documents.
The key of the map is <policy_name> and the value of the map is a policy document.
*/
module "iam_groups" {
  source = "../iam_groups"

  across_account_groups = {
    for k, v in module.iam_policies.group_assume_policies_map :
    k => v.json
  }
  self_account_groups = {
    for group_name, v in local.self_account_groups :
    group_name => v.iam_policy
    if contains(var.user_groups[*].group_name, group_name)
  }

  user_groups = var.user_groups
}

//Create roles according to the predefined Permissions policies for IAM roles
module "iam_roles" {
  source        = "../iam_roles"
  role_policies = module.iam_policies.role_policies_map
}

resource "aws_organizations_organization" "org" {
  count = var.create_organization ? 1 : 0
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
  ]

  feature_set = "ALL"
}

resource "aws_organizations_account" "accounts" {
  for_each = var.child_accounts
  name  = each.key
  email = each.value.email
}