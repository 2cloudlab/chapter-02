variable "should_require_mfa" {
  description = "Should we require that all IAM Users use Multi-Factor Authentication for both AWS API calls and the AWS Web Console? (true or false)"
  type        = bool
  default = true
}

variable "read_only_access_identifiers" {
  type = list(string)
  default = []
}
