variable "should_require_mfa" {
  type    = bool
  default = true
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
  type    = map(list(string))
  default = {}
}

variable "iam_users" {
  description = ""
  type = map(object({
    group_name_arr    = list(string)
    pgp_key           = string
    create_access_key = bool
  }))
  default = {
  }
}

variable "second_layer_child_accounts" {
  description = ""
  type = map(object(
    {
      email = string
    }
  ))
  default = {}
}

variable "third_layer_child_accounts" {
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
  description = "Set true for creating an organization in master account. Only set true in master account, false for child accounts."
  type        = bool
  default     = false
}

variable "second_layer_ous" {
  description = ""
  type        = set(string)
  default     = []
}

variable "third_layer_ous" {
  description = ""
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