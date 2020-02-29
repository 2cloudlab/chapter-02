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
create an IAM group.
*/

# create an IAM group
resource "aws_iam_group" "group" {
  for_each = local.group_map
  name = each.value.group_name
}

# create custom managed policy
resource "aws_iam_policy" "custom_managed_policy" {
  for_each = local.group_map
  name        = each.value.policy_name
  description = each.value.policy_description
  policy      = each.value.policy_doc
}

# create attachment, it will attach policy to group without affecting existed policies
resource "aws_iam_group_policy_attachment" "group_attachment" {
  for_each = local.group_map
  group      = aws_iam_group.group[each.key].name
  policy_arn = aws_iam_policy.custom_managed_policy[each.key].arn
}