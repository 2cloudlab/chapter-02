output "group_obj" {
  value = module.iam_groups.group_obj
}

output "user_login_keys" {
  value = module.iam_groups.user_login_keys
}

output "policy_doc" {
  value = module.iam_policies.policy_map["AdministratorAccess"]
}