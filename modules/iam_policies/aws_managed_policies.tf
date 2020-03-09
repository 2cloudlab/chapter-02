// retrive aws managed policy and merge with mfa condition
locals {
  _aws_managed_policy_json_object = {
    for k, v in data.aws_iam_policy.aws_managed_policies :
    k => jsondecode(v.policy)
  }
  aws_managed_policies = {
    for k, v in local._aws_managed_policy_json_object :
    k => jsonencode(
      merge(v, {
        Statement = [for statement in v["Statement"] : merge(statement,
          var.should_require_mfa ? {
            Condition = {
              Bool = {
                "aws:MultiFactorAuthPresent" = "true"
              }
            }
          } : {})
        ]
        }
      )
    )
  }
  aws_managed_policy_arns = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
    Billing = "arn:aws:iam::aws:policy/job-function/Billing"
  }
  //out-of-box IAM policies, which is used for attaching to groups
  output_policy_map = {
    AdministratorAccess = {
      policy_name        = "AdministratorAccess",
      policy_description = "Same as AWS Managed AdministratorAccess policy, but can config with MFA.",
      policy_doc         = data.aws_iam_policy_document.full_access.json
    }
    Billing = {
      policy_name        = "Billing",
      policy_description = "Same as AWS Managed Billing policy, but can config with MFA.",
      policy_doc         = data.aws_iam_policy_document.billing_access.json
    }
  }
}

data "aws_iam_policy" "aws_managed_policies" {
  for_each = local.aws_managed_policy_arns
  arn      = each.value
}

/*
Create full_access policy.

This policy will give admin permissions to user. Attach it to group and add user to that group 
*/

data "aws_iam_policy_document" "full_access" {
  source_json   = local.first_time_login_without_mfa_json
  override_json = local.aws_managed_policies["AdministratorAccess"]
}

data "aws_iam_policy_document" "billing_access" {
  source_json   = local.first_time_login_without_mfa_json
  override_json = local.aws_managed_policies["Billing"]
}

// aws managed billing policy

