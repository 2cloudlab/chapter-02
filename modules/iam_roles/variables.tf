variable "role_policies" {
    type = map(
        object({
        type = string
        identifiers = list(string)
        assume_role_policy = string
        iam_policy_name = string
        iam_policy_description = string
        iam_policy = string
    }))

    default = {
        full_access_role = {
            type = "AWS"
            identifiers = ["account 1", "account 2"]
            assume_role_policy = ""
            iam_policy_name = "full_access"
            iam_policy_description = "full access description"
            iam_policy = ""
        }
    }
}