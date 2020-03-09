terraform {
  required_version = "= 0.12.19"
}

locals {
  self_account_groups = {
    full_access = {
      iam_policy = module.iam_policies.policy_map["AdministratorAccess"]
      should_created = var.should_create_iam_group_full_access
    }
    billing = {
      iam_policy = module.iam_policies.policy_map["Billing"]
      should_created = var.should_create_iam_group_billing
    }
  }
}


module "iam_policies" {
  source                                         = "../../modules/iam_policies"
  should_require_mfa                             = var.should_require_mfa
  allow_read_only_access_from_other_account_arns = var.allow_read_only_access_from_other_account_arns
}

module "iam_policies_with_role_arns" {
  source                                   = "../../modules/iam_policies"
  should_require_mfa                       = var.should_require_mfa
  across_account_access_role_arns_by_group = var.across_account_access_role_arns_by_group
}

/*
Create an IAM group and attach a policy to it.
<policy_doc> is retrived from iam_policies module which defines a map of policy documents.
The key of the map is <policy_name> and the value of the map is a policy document.
*/
module "iam_groups" {
  source = "../../modules/iam_groups"

  across_account_groups = {
    for k, v in module.iam_policies_with_role_arns.group_assume_policies_map :
    k => v.json
  }
  self_account_groups = {
      for k,v in local.self_account_groups:
      k => v.iam_policy
      if v.should_created
  }

  user_groups = var.user_groups
}

//create role
module "iam_roles" {
  source        = "../../modules/iam_roles"
  role_policies = module.iam_policies.role_policies_map
}
