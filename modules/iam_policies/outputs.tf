output "policy_map" {
    value = local.policy_map
}

output "role_policies_map" {
    value = {
      for key, value in local.role_policies_map:
      key => merge(value, {
        assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policies[key].json
      })
    }
}
/*
output "billing" {
  value = data.aws_iam_policy_document.billing.json
}
output "developers" {
  value = data.aws_iam_policy_document.developers.json
}
output "developers_s3_bucket" {
  value = data.aws_iam_policy_document.developers_s3_bucket.json
}
output "read_only" {
  value = data.aws_iam_policy_document.read_only.json
}
output "use_existing_iam_roles" {
  value = data.aws_iam_policy_document.use_existing_iam_roles.json
}
*/