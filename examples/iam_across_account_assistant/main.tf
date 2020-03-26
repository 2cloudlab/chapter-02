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
  //organization related
  create_organization = var.create_organization
  second_layer_child_accounts = var.second_layer_child_accounts
  third_layer_child_accounts = var.third_layer_child_accounts
  fourth_layer_child_accounts = var.fourth_layer_child_accounts
  fifth_layer_child_accounts = var.fifth_layer_child_accounts

  second_layer_ous = var.second_layer_ous
  third_layer_ous = var.third_layer_ous
  fourth_layer_ous = var.fourth_layer_ous
}
