
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


variable "iam_users" {
  description = ""
  type = map(object({
    group_name_arr    = list(string)
    pgp_key           = string
    create_access_key = bool
  }))
  default = {}
}
