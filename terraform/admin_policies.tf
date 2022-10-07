data "aws_iam_policy_document" "caascad_administrator_operator_policy" {
  statement {
    actions = [
      "*",
    ]
    resources = [
      "*",
    ]
  }
}
