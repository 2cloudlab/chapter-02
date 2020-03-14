output "user_login_keys" {
  value = module.iam_groups.user_login_keys
}

output "group_2_role_map" {
  value = module.iam_roles.roles_map
}

output "name_of_group_arr" {
  value = module.iam_groups.name_of_group_arr
}
