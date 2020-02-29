terraform {
  required_version = "= 0.12.19"
}

provider "aws" {
  version = "= 2.46"
  region  = "us-east-2"
}

module "iam_policies" {
  source = "../../modules/iam_policies"
  should_require_mfa = true
}

module "iam_groups" {
  source = "../../modules/iam_groups"
  group_name = "full_access"
  policy_name = "AdministratorAccess"
  policy_description = "Same as AWS Managed AdministratorAccess, but can config with MFA"
  policy_doc = module.iam_policies.policy_map["AdministratorAccess"]
}