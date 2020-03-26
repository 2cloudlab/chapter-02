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
      create_access_key = bool
    }))
  }))
  default = []
}

variable "second_layer_child_accounts" {
  description = ""
  type = map(object(
    {
      email = string
    }
  ))
  default = {}
}

variable "third_layer_child_accounts" {
  description = ""
  type = map(object(
    {
      email = string
      parent_id = string
    }
  ))
  default = {    
  }
}

variable "fourth_layer_child_accounts" {
  description = ""
  type = map(object(
    {
      email = string
      parent_id = string
    }
  ))
  default = {    
  }
}

variable "fifth_layer_child_accounts" {
  description = ""
  type = map(object(
    {
      email = string
      parent_id = string
    }
  ))
  default = {    
  }
}

variable "create_organization" {
  description = "Set true for creating an organization in master account. Only set true in master account, false for child accounts."
  type        = bool
  default = false
}

variable "second_layer_ous" {
  description =""
  type = set(string)
  default = []
}

variable "third_layer_ous" {
  description =""
  type = map(object(
    {
      parent_id = string
    }
  ))
  default = {
  }
}

variable "fourth_layer_ous" {
  description =""
  type = map(object(
    {
      parent_id = string
    }
  ))
  default = {
  }
}