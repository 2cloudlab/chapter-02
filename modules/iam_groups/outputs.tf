output "group_obj" {
    value = aws_iam_group.groups
}

output "user_login_keys" {
  value = aws_iam_user_login_profile.user_login_profiles
}
