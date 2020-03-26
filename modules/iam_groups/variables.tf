
variable "self_account_groups" {
  description = "creating multiple groups"
  type = map(object({
    policy_name        = string
    policy_description = string
    policy_doc         = string
  }))

  default = {}
}

variable "across_account_groups" {
  type    = map(string)
  default = {}
}


variable "user_groups" {
  description = ""
  type = list(object({
    group_name = string
    user_profiles = list(object({
      pgp_key           = string
      user_name         = string
      create_access_key = bool
    }))
  }))
  default = []
}
