variable "group_name" {
  description = "The name of IAM group"
  type        = string
}

variable "policy_name" {
  description = "The name of IAM policy"
  type        = string
}

variable "policy_description" {
  description = "The description of IAM policy"
  type        = string
}

variable "policy_doc" {
    description = "policy document which is attached to group"
    type = string
}