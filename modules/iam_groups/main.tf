terraform {
  required_version = "= 0.12.19"
}

/*
create multiple IAM groups.
*/

# create multiple IAM groups
locals {
  _max_policy_size_in_bytes = 2044
  _policy_name_to_policy_map = {
    for group_name, policy in var.self_account_groups:
    policy.policy_name => merge(policy,
    {
      "group_name" = group_name
      policy_obj = jsondecode(policy.policy_doc)
      number_of_policy = ceil(length(policy.policy_doc) / local._max_policy_size_in_bytes)
    }
    )
  }
  policy_name_to_policy_map = {
    for policy in flatten(
      [
        for policy_name, policy_obj in local._policy_name_to_policy_map: [
          for i in range(policy_obj.number_of_policy): merge(policy_obj, 
          {
            "policy_name" = format("%s%s", policy_name, policy_obj.number_of_policy == 1 ? "" : format("%d",i))
            index = i
            is_single_policy = policy_obj.number_of_policy == 1 ? true : false
            action = policy_obj.number_of_policy == 1 ? [] : element(chunklist(
              policy_obj.policy_obj.Statement[length(policy_obj.policy_obj.Statement) - 1].Action, ceil(
                length(policy_obj.policy_obj.Statement[length(policy_obj.policy_obj.Statement) - 1].Action) / policy_obj.number_of_policy)),i)
          })
        ]
      ]
    ):
    policy.policy_name => policy
  }

  final_policy_name_to_policy_map = {
    for policy_name, policy_obj in local.policy_name_to_policy_map:
    policy_name => merge(
      policy_obj, {
        policy_doc = policy_obj.is_single_policy ? policy_obj.policy_doc : jsonencode(
          merge(policy_obj.policy_obj, {
            Statement = concat(slice(policy_obj.policy_obj.Statement, 0, length(policy_obj.policy_obj.Statement) - 1), [
              merge(policy_obj.policy_obj.Statement[length(policy_obj.policy_obj.Statement) - 1], {
                Action = policy_obj.action
              })
            ])
          })
        )
      }
    )
  }
}

resource "aws_iam_group" "groups" {
  for_each = var.self_account_groups
  name     = each.key
}

# create custom managed policies
resource "aws_iam_policy" "custom_managed_policy" {
  for_each    = local.final_policy_name_to_policy_map
  name        = each.key
  description = each.value.policy_description
  policy      = each.value.policy_doc
}

# create attachment, it will attach policy to corresponsd group without affecting existed policies
resource "aws_iam_group_policy_attachment" "group_attachment" {
  for_each   = local.final_policy_name_to_policy_map
  group      = aws_iam_group.groups[each.value.group_name].name
  policy_arn = aws_iam_policy.custom_managed_policy[each.key].arn
}

#
#
# create group with inline policy

resource "aws_iam_group" "across_account_groups" {
  for_each = var.across_account_groups
  name     = each.key
}

resource "aws_iam_group_policy" "inline_policis" {
  for_each = var.across_account_groups
  group    = aws_iam_group.across_account_groups[each.key].id

  policy = each.value
}


/*
Create multiple users
*/

resource "aws_iam_user" "users" {
  for_each = var.iam_users
  //When destroying this user, destroy even if it has non-Terraform-managed IAM access keys, login profile or MFA devices. Without force_destroy a user with non-Terraform-managed access keys and login profile will fail to be destroyed.
  force_destroy = true
  name          = each.key
}

resource "aws_iam_access_key" "credentials" {
  for_each = {
    for user_name, user_instance in aws_iam_user.users :
    user_name => user_instance
    if var.iam_users[user_name].create_access_key
  }
  user    = each.key
  pgp_key = var.iam_users[each.key].pgp_key
}

/*
pgp_key is encrypted and encoded by base-64, or keybase:<user_name>, whoes user_name is registered from keybase.io.

After aws_iam_user_login_profile was created, it will generated a encrpted password encoding with base-64.
Give encrypted password and user name to the correspond user, then, the user can install and login to keybase.
Run the following command to decrypted the encrypted password

echo <encrypted_password> | base64 -D | keybase pgp decrypt

The command will output a plain text, which is the password for logining to AWS
*/
resource "aws_iam_user_login_profile" "user_login_profiles" {
  for_each = aws_iam_user.users
  user     = each.key
  pgp_key  = var.iam_users[each.key].pgp_key
}

resource "aws_iam_user_group_membership" "user_group_membership" {
  for_each = aws_iam_user.users
  user     = each.key

  groups = var.iam_users[each.key].group_name_arr

  depends_on = [
    aws_iam_group.groups,
  ]
}