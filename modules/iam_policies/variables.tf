variable "should_require_mfa" {
  description = "Should we require that all IAM Users use Multi-Factor Authentication for both AWS API calls and the AWS Web Console? (true or false)"
  type        = bool
  default     = true
}

variable "allow_read_only_access_from_other_account_arns" {
  type    = list(string)
  default = []
}

variable "across_account_access_role_arns_by_group" {
  type    = map(list(string))
  default = {}
}