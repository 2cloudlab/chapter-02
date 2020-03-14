variable "should_require_mfa" {
  type    = bool
  default = true
}

variable "allow_read_only_access_from_other_account_arns" {
  type    = list(string)
  default = []
}

variable "across_account_access_role_arns_by_group" {
  type    = map(list(string))
  default = {}
}

variable "user_groups" {
  type    = list(object({
        group_name = string
        user_profiles = list(object({
            pgp_key = string
            user_name = string
            }))
    }))
  default = []
  /*
  [{
    group_name = "billing"
    user_profiles = [
      {
        user_name = "Jim",
        pgp_key   = "keybase:freshairfreshliv"
      }
    ]
  }]
  */
}
