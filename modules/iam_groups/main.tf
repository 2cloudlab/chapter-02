terraform {
    required_version = "= 0.12.19"
}

/*
create multiple IAM groups.
*/

# create multiple IAM groups
resource "aws_iam_group" "groups" {
  for_each = var.self_account_groups
  name = each.key
}

# create custom managed policies
resource "aws_iam_policy" "custom_managed_policy" {
  for_each = var.self_account_groups
  name        = each.value.policy_name
  description = each.value.policy_description
  policy      = each.value.policy_doc
}

# create attachment, it will attach policy to corresponsd group without affecting existed policies
resource "aws_iam_group_policy_attachment" "group_attachment" {
  for_each = var.self_account_groups
  group      = aws_iam_group.groups[each.key].name
  policy_arn = aws_iam_policy.custom_managed_policy[each.key].arn
}

#
#
# create group with inline policy

resource "aws_iam_group" "across_account_groups" {
  for_each = var.across_account_groups
  name = each.key
}

resource "aws_iam_group_policy" "inline_policis" {
  for_each = var.across_account_groups
  group = aws_iam_group.across_account_groups[each.key].id

  policy = each.value
}


/*
Create multiple users
*/

locals{
  user_profile_group_map = {
    for user in flatten([
      for user_group in var.user_groups: [
        for user_profile in user_group.user_profiles:{
          user_name = user_profile.user_name
          group_name = user_group.group_name
          pgp_key = user_profile.pgp_key
        }
      ]
    ]):
    user.user_name => { 
      "group_name" = user.group_name,
      "pgp_key" = user.pgp_key
    }
  }
}

resource "aws_iam_user" "users" {
  for_each = local.user_profile_group_map
  name = each.key
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
  user    = each.key
  pgp_key = local.user_profile_group_map[each.key].pgp_key
}

resource "aws_iam_user_group_membership" "user_group_membership" {
  for_each = aws_iam_user.users
  user = each.key

  groups = [
    #user name -> group name -> group resource -> group name
    #this method can make user_group_membership depend on group resource
    #after establish this relation, it make sure to destroy group resource before destroying user_group_membership resource
    aws_iam_group.groups[local.user_profile_group_map[each.key].group_name].name,
  ]
}