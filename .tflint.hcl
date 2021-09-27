config {
  disabled_by_default = false
}

plugin "aws" {
  enabled = true
}

rule "aws_iam_policy_invalid_name" {
  enabled = false
}

rule "aws_iam_user_invalid_name" {
  enabled = false
}

rule "aws_iam_role_invalid_name" {
  enabled = false
}

rule "aws_iam_user_policy_invalid_name" {
  enabled = false
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}
