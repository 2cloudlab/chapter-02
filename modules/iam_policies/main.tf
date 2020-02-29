terraform {
    required_version = "= 0.12.19"
}

/*
data "aws_iam_policy_document" "example" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "",
        "home/",
        "home/&{aws:username}/",
      ]
    }
  }

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}/home/&{aws:username}",
      "arn:aws:s3:::${var.s3_bucket_name}/home/&{aws:username}/*",
    ]
  }
}
*/

locals {
    policy_map = {
        "AdministratorAccess" = data.aws_iam_policy_document.full_access.json,
    }
    mfa_condition_block = var.should_require_mfa ? [{"test"="Bool","variable"="aws:MultiFactorAuthPresent","values"=[true,]}] : []
}

data "aws_iam_policy_document" "full_access" {
  statement {
    sid = "FullAccess"
      
    actions = [
      "*",
    ]

    resources = [
      "*",
    ]

    dynamic "condition" {
        for_each = local.mfa_condition_block
        content{
            test = condition.value["test"]
            variable = condition.value["variable"]
            values = condition.value["values"]
        }
    }
  }
}

/*
condition {
        test = "Bool"
        variable = "aws:MultiFactorAuthPresent"
        values = [
            true,
        ]
    }
*/
#
#
# create group with inline policy

/*
resource "aws_iam_group" "developers" {
  name = "developers"
}

resource "aws_iam_group_policy" "my_developer_policy" {
  name  = "my_developer_policy"
  group = aws_iam_group.developers.id

  policy = data.aws_iam_policy_document.full_access.json
}
*/