iam_users = {
  cloudtest = {
    group_name_arr    = ["read_only",]
    pgp_key           = "keybase:freshairfreshliv"
    create_access_key = false
  }
}

should_require_mfa = true