//-------------------------------------------------------------------------
// Use this module to create across accounts strategy and organization related components.
//
// Set var.should_require_mfa to true to enable MFA for all policies.
//
// Groups to be created: 
//     1. full_access
//     2. billing
//
// Roles to be created:
//     1. allow_read_only_access_from_other_accounts
//     2. allow_full_access_from_other_accounts
//     3. allow_billing_access_from_other_accounts
// 
//-------------------------------------------------------------------------

variable "should_require_mfa" {
  description = <<EOF
  Should we require that all IAM Users use Multi-Factor Authentication for both AWS API calls and the AWS Web Console? (true or false)
  EOF
  type        = bool
  default     = true
}

variable "allow_read_only_access_from_other_account_arns" {
  description=<<EOF
  Create a read-only policy for listed account arns.
  Checkout https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_principal.html
  for the format of different types of arns.
  IAM users in listed accounts can assume a role attached with this policy.
  For example:
  default = [
    "arn:aws:iam::123456789012:root", # dev account, same as "123456789012"
    "777777777777", # stage
    "888888888888", # prod
    "999999999999", # shared-services
    "arn:aws:iam::AWS-account-ID:user/user-name-1", # for a specific user
  ] 
  EOF
  type    = list(string)
  default = []
}

variable "allow_full_access_from_other_account_arns" {
  description=<<EOF
  The usage is same as var.allow_read_only_access_from_other_account_arns, but with a different of
  creating a full-access policy.
  EOF
  type = list(string)
  default =[]
}

variable "allow_billing_access_from_other_account_arns" {
  description=<<EOF
  The usage is same as var.allow_read_only_access_from_other_account_arns, but with a different of
  creating a billing-access policy.
  EOF
  type = list(string)
  default =[]
}

variable "across_account_access_role_arns_by_group" {
  description =<<EOF
  Create groups with sts:AssumeRole permissions to assume roles in other accounts.
  The key is the group name.
  The value is a list of role arns in other accounts.
  For example:
  default = {
    _account_dev_read_only_access = [
      "arn:aws:iam::<12-digits-AWS-account-ID>:role/allow_read_only_access_from_other_accounts",
    ],
    _account_stage_full_access = [
      "arn:aws:iam::<12-digits-AWS-account-ID>:role/allow_full_access_from_other_accounts",
    ],
    _account_stage_developers_access = [
      "arn:aws:iam::<12-digits-AWS-account-ID>:role/allow_full_access_from_other_accounts",
    ],
  }
  EOF
  type    = map(list(string))
  default = {}
}

variable "iam_users" {
  description = <<EOF
  IAM users to be created in a security account.
  The key is a unique user name.
  The value is details info for users, such as pgp key.
  For example:
  default = {
    jane = {
      group_name_arr = ["full_access", "billing",]
      pgp_key = "keybase:jane"
      create_access_key = true
    }
  }
  EOF
  type = map(object({
    group_name_arr = list(string)
    pgp_key           = string
    create_access_key = bool
    }))
  default = {}
}

//-----------------------------------------------
// Organization related options which can only be used in master account.
// Setting these vars can help you to create a hierarchical accounts solution.
//-----------------------------------------------

variable "second_layer_child_accounts" {
  description = <<EOF
  Child accounts to be created on the second layer, that means the parent of these accounts is Organization root.
  EOF
  type = map(object(
    {
      email = string
    }
  ))
  default = {}
}

variable "third_layer_child_accounts" {
  description = <<EOF
  Child accounts to be created on the third layer.
  It means the parent of these accounts is Organization Unit in the second layer.
  EOF
  type = map(object(
    {
      email     = string
      parent_id = string
    }
  ))
  default = {
  }
}

variable "fourth_layer_child_accounts" {
  description = ""
  type = map(object(
    {
      email     = string
      parent_id = string
    }
  ))
  default = {
  }
}

variable "fifth_layer_child_accounts" {
  description = ""
  type = map(object(
    {
      email     = string
      parent_id = string
    }
  ))
  default = {
  }
}

variable "create_organization" {
  description = <<EOF
  Set true for creating an organization in master account.
  Only set true in master account, false for child accounts.
  EOF
  type        = bool
  default     = false
}

variable "second_layer_ous" {
  description = <<EOF
  Organization Units to be created on second layer.
  It means the parent id of these organization units is root id in master account. 
  The value in set is a unique name for each organization unit.
  EOF
  type        = set(string)
  default     = []
}

variable "third_layer_ous" {
  description = <<EOF
  Organization Units to be created on third layer.
  The key is the unique name of each organization unit.
  The value are an object, which contains a property named parent_id.
  The parent_id can be either of following cases:
  1. The key of each organization unit in second_layer_ous
  2. The id of exist organization unit in master account.
  EOF

  type = map(object(
    {
      parent_id = string
    }
  ))
  default = {
  }
}

variable "fourth_layer_ous" {
  description = ""
  type = map(object(
    {
      parent_id = string
    }
  ))
  default = {
  }
}