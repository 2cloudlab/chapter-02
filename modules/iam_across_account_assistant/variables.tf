variable "should_require_mfa" {
  type    = bool
  default = true
}

variable "allow_read_only_access_from_other_account_arns" {
  description = ""
  type        = list(string)
  default     = []
}

variable "across_account_access_role_arns_by_group" {
  type    = map(list(string))
  default = {}
}

variable "user_groups" {
  description = "A list of groups with corresponding users in each group."
  type = list(object({
    group_name = string
    user_profiles = list(object({
      pgp_key   = string
      user_name = string
    }))
  }))
  default = []
}