
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