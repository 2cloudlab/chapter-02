output "policy_map" {
  value       = local.output_policy_map
  description = "Contain AWS managed policies, Customer managed policies"
}

output "role_policies_map" {
  value = local.output_role_policies_map
}

output "group_assume_policies_map" {
  value = local.output_group_assume_policies_map
}