terraform {
    required_version = "= 0.12.19"
}

locals {
  group_map = {
    for value in var.group_detail:
    value.group_name => value
  }
}

/*
create multiple IAM groups.
*/

# create multiple IAM groups
resource "aws_iam_group" "group" {
  for_each = local.group_map
  name = each.value.group_name
}

# create custom managed policies
resource "aws_iam_policy" "custom_managed_policy" {
  for_each = local.group_map
  name        = each.value.policy_name
  description = each.value.policy_description
  policy      = each.value.policy_doc
}

# create attachment, it will attach policy to corresponsd group without affecting existed policies
resource "aws_iam_group_policy_attachment" "group_attachment" {
  for_each = local.group_map
  group      = aws_iam_group.group[each.key].name
  policy_arn = aws_iam_policy.custom_managed_policy[each.key].arn
}

/*
Create multiple users
*/

locals{
  user_group_map = {
    for g_u in flatten([
      for user in var.users: [
        for name in user.users_name:{
          user_name = name
          group_name = user.group_name
        }
      ]
    ]):
    g_u.user_name => g_u.group_name
  }
}

resource "aws_iam_user" "users" {
  for_each = local.user_group_map
  name = each.key
}

resource "aws_iam_user_group_membership" "user_group_membership" {
  for_each = local.user_group_map
  user = each.key

  groups = [
    each.value,
  ]
}