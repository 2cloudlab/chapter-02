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
  should_require_mfa = true
  across_account_access_role_arns_by_group = {}
  should_create_iam_group_full_access = true
  should_create_iam_group_billing = false
  user_groups = [{
    group_name = "full_access"
    user_profiles = [
      {
        user_name = "Tony",
        pgp_key   = "keybase:freshairfreshliv"
      }
    ]
  }]
}
