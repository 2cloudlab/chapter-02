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
      "iam:ChangePassword",         # force user who login first time can change password
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
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"

      values = [
        "false",
      ]
    }
  }
}