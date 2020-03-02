terraform {
    required_version = "= 0.12.19"
}

/*
data "aws_iam_policy_document" "example" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "",
        "home/",
        "home/&{aws:username}/",
      ]
    }
  }

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}/home/&{aws:username}",
      "arn:aws:s3:::${var.s3_bucket_name}/home/&{aws:username}/*",
    ]
  }
}
*/

locals {
    policy_map = {
        "AdministratorAccess" = data.aws_iam_policy_document.full_access.json,
    }
    mfa_condition_block = var.should_require_mfa ? [{"test"="Bool","variable"="aws:MultiFactorAuthPresent","values"=[true,]}] : []
}

/*
Create full_access policy.

This policy will give admin permissions to user. Attach it to group and add user to that group 
*/
data "aws_iam_policy_document" "full_access" {
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
        content{
            test = condition.value["test"]
            variable = condition.value["variable"]
            values = condition.value["values"]
        }
    }
  }

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