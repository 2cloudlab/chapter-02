terraform {
    required_version = "= 0.12.19"
}

locals {
    //out-of-box IAM policies, which is used for attaching to groups
    output_policy_map = {
        AdministratorAccess = {
            policy_name        = "AdministratorAccess",
            policy_description = "Same as AWS Managed AdministratorAccess, but can config with MFA",
            policy_doc = data.aws_iam_policy_document.full_access.json
        }
    }
    //true for turning on mfa access for all policies.
    mfa_condition_block = var.should_require_mfa ? [{"test"="Bool","variable"="aws:MultiFactorAuthPresent","values"=[true,]}] : []
    //base policy for mfa, this policy is a source of each policy which is designed to support mfa access
    first_time_login_without_mfa_json = var.should_require_mfa ? data.aws_iam_policy_document.first_time_login_without_mfa_base.json : data.aws_iam_policy_document.disable_mfa.json

    //role_policies_map depend on predefined_role_policies_map
    //role_policies_map automatically filter empty identifiers out from predefined_role_policies_map
    predefined_role_policies_map = {
        read_only_access = {
            type = "AWS"
            identifiers = var.allow_read_only_access_from_other_account_arns
            iam_policy_name        = "read_only_access"
            iam_policy_description = "Attach this policy to role in account B, it allow read only access from other accounts, such as account A."
            iam_policy = data.aws_iam_policy.read_only_access_iam_policy_for_role.policy
        }
    }
    role_policies_map = {
        for k,v in local.predefined_role_policies_map:
        k => v
        if length(v.identifiers) != 0
    }

    output_role_policies_map = {
      for k, v in local.role_policies_map:
      k => merge(v, {
        assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policies[k].json
      })
    }

    output_group_assume_policies_map = data.aws_iam_policy_document.iam_policy_attach_to_group
}

# Empty policy which is used for disable mfa
data "aws_iam_policy_document" "disable_mfa" {

}

# first-time login with MFA base policy which should be specified to each other policy document
# when user login to AWS first time, this policy will be in effect, which force he/she to add MFA device
data "aws_iam_policy_document" "first_time_login_without_mfa_base" {
  # This permission must be in its own statement because it does not support specifying a resource ARN. Instead you must specify "Resource" : "*"
  statement {
    sid = "AllowViewDetailVirtualMFADevicesInfo"

    effect = "Allow"

    actions = [
      "iam:ListVirtualMFADevices",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "AllowManageOwnVirtualMFADevice"

    effect = "Allow"

    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice"
    ]

    resources = [
      "arn:aws:iam::*:mfa/&{aws:username}"
    ]
  }

  statement {
    sid = "AllowIndividualUserToSeeAndManageOnlyTheirOwnAccountInformation"

    effect = "Allow"

    actions = [
      "iam:ChangePassword",
      "iam:DeactivateMFADevice",
      "iam:EnableMFADevice",
      "iam:GetUser",
      "iam:ListMFADevices",
      "iam:ResyncMFADevice"
    ]

    resources = [
      "arn:aws:iam::*:user/&{aws:username}"
    ]
  }
  
  statement {
    sid = "BlockMostAccessUnlessSignedInWithMFA"

    effect = "Deny"
    # force user to the listed actions if he/she does not provide MFA code.
    # This statement ensures that when the user is not signed in with MFA, they can perform only the listed actions.
    # In addition, they can perform the listed actions only if another statement or policy allows access to those actions.
    not_actions = [
      "iam:ChangePassword", # force user who login first time can change password
      "iam:DeleteVirtualMFADevice", # add this action in case user partially adds MFA device but quit to do other thing
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:GetUser",
      "iam:ListMFADevices",
      "iam:ListVirtualMFADevices",
      "iam:ResyncMFADevice",
      # No permissions are required for a user to get a session token.
      # The purpose of the GetSessionToken operation is to authenticate the user using MFA.
      # You cannot use policies to control authentication operations.
      "sts:GetSessionToken"
    ]

    resources = [
      "*"
    ]

    condition {
      test = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"

      values = [
        "false",
      ]
    }
  }
}

/*
Create full_access policy.

This policy will give admin permissions to user. Attach it to group and add user to that group 
*/
data "aws_iam_policy_document" "full_access" {
  source_json = local.first_time_login_without_mfa_json
  statement {
    sid = "FullAccess"
      
    actions = [
      "*",
    ]

    resources = [
      "*",
    ]
    
    dynamic "condition" {
        for_each = local.mfa_condition_block
        content {
            test = condition.value["test"]
            variable = condition.value["variable"]
            values = condition.value["values"]
        }
    }
  }
}


// trust policy for roles
// generating by permission policies
data "aws_iam_policy_document" "instance_assume_role_policies" {
    for_each = local.role_policies_map

    statement {
        actions = ["sts:AssumeRole"]
        
        principals {
            type = each.value.type
            identifiers = each.value.identifiers
        }
        
        dynamic "condition" {
            for_each = local.mfa_condition_block
            content {
                test = condition.value["test"]
                variable = condition.value["variable"]
                values = condition.value["values"]
            }
        }
    }
}

//read only access policy for roles
data "aws_iam_policy" "read_only_access_iam_policy_for_role" {
  arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

// an IAM policy which is attached to group, this group is used for assuming roles in other accounts
data "aws_iam_policy_document" "iam_policy_attach_to_group" {
  for_each = var.across_account_access_role_arns_by_group
  statement {
        actions = ["sts:AssumeRole"]
        
        resources = each.value
        
        dynamic "condition" {
            for_each = local.mfa_condition_block
            content {
                test = condition.value["test"]
                variable = condition.value["variable"]
                values = condition.value["values"]
            }
        }
    }
}