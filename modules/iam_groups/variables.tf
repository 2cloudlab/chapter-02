
variable "group_detail" {
  description = "creating multiple groups"
  type = list(object({
    group_name  = string
    policy_name = string
    policy_description = string
    policy_doc = string
  }))

  default = []
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
