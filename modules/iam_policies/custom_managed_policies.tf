// custom managed policy
data "aws_iam_policy_document" "custom_managed_policy" {
  source_json = local.first_time_login_without_mfa_json
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
      content {
        test     = condition.value["test"]
        variable = condition.value["variable"]
        values   = condition.value["values"]
      }
    }
  }
}