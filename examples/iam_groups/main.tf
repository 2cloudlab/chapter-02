terraform {
  required_version = "= 0.12.19"
}

provider "aws" {
  version = "= 2.46"
  region  = "us-east-2"
}

//create role
module "iam_across_account_assistant" {
  source        = "../../modules/iam_across_account_assistant"
  allow_read_only_access_from_other_account_arns = []
  should_require_mfa = false
  across_account_access_role_arns_by_group = {}
  should_create_iam_group_full_access = false
  should_create_iam_group_billing = true
  user_groups = [{
    group_name = "billing"
    user_profiles = [
      {
        user_name = "Tony",
        pgp_key   = "keybase:freshairfreshliv"
      }
    ]
  }]
}
