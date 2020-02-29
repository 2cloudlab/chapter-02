terraform {
  required_version = "= 0.12.19"
}

provider "aws" {
  version = "= 2.46"
  region  = "us-east-2"
}

module "iam_policies" {
  source             = "../../modules/iam_policies"
  should_require_mfa = true
}

/*
Create an IAM group and attach a policy to it.
<policy_doc> is retrived from iam_policies module which defines a map of policy documents.
The key of the map is <policy_name> and the value of the map is a policy document.
*/
module "iam_groups" {
  source = "../../modules/iam_groups"
  group_detail = [
    {
      group_name         = "full_access",
      policy_name        = "AdministratorAccess",
      policy_description = "Same as AWS Managed AdministratorAccess, but can config with MFA",
      policy_doc         = module.iam_policies.policy_map["AdministratorAccess"]
    }
  ]

  users = [{
    group_name = "full_access"
    users_name = ["Tony", "Jane", "Jack"]
  }]
}