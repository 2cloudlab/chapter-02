variable "allow_read_only_access_from_other_account_arns" {
  type    = list(string)
  default = []
}

variable "should_require_mfa" {
  type    = bool
  default = true
}

variable "across_account_access_role_arns_by_group" {
  type    = map(list(string))
  default = {}
}

variable "should_create_iam_group_full_access" {
  type = bool
  default = false
}

variable "should_create_iam_group_billing" {
  type = bool
  default = false
}


variable "user_groups" {
    description=""
    type = list(object({
        group_name = string
        user_profiles = list(object({
            pgp_key = string
            user_name = string
            }))
    }))
    default = []
}