terraform {
  required_version = "= 0.12.19"
}

provider "aws" {
  version = "= 2.46"
  region  = "us-east-2"
}

//create role
module "iam_across_account_assistant" {
  source                                         = "../../modules/iam_across_account_assistant"
  allow_read_only_access_from_other_account_arns = var.allow_read_only_access_from_other_account_arns
  should_require_mfa                             = var.should_require_mfa
  across_account_access_role_arns_by_group       = var.across_account_access_role_arns_by_group
  user_groups = var.user_groups
}
