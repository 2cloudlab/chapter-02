terraform {
    required_version = "= 0.12.19"
}

/*
create an IAM group.
*/

# create an IAM group
resource "aws_iam_group" "group" {
  name = var.group_name
}

# create custom managed policy
resource "aws_iam_policy" "custom_managed_policy" {
  name        = var.policy_name
  description = var.policy_description
  policy      = var.policy_doc
}

# create attachment, it will attach policy to group without affecting existed policies
resource "aws_iam_group_policy_attachment" "group_attachment" {
  group      = aws_iam_group.group.name
  policy_arn = aws_iam_policy.custom_managed_policy.arn
}