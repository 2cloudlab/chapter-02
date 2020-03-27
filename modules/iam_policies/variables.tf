variable "should_require_mfa" {
  description = <<EOF
  Should we require that all IAM Users use Multi-Factor Authentication for both AWS API calls and the AWS Web Console? (true or false)
  EOF
  type        = bool
  default     = true
}

variable "allow_read_only_access_from_other_account_arns" {
  description=<<EOF
  Create a read-only role for listed account arns.
  IAM users in listed accounts can assume this role for read-only permissions.
  For example:
  default = [
    "666666666666", # dev
    "777777777777", # stage
    "888888888888", # prod
    "999999999999", # shared-services
  ] 
  EOF
  type    = list(string)
  default = []
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