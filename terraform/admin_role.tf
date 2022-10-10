data "aws_iam_policy_document" "caascad_administrator_operator_assumerole_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.caascad_operator_trusted_arn]
    }
  }
}

resource "aws_iam_role" "caascad_administrator_operator" {
  count = var.add_admin ? 1 : 0
  name        = "caascad-administrator-operator"
  description = "Role used for Caascad administration"

  force_detach_policies = true

  max_session_duration = 10 * 60 * 60 // 10h

  assume_role_policy = data.aws_iam_policy_document.caascad_administrator_operator_assumerole_policy.json

  tags = {
    caascad       = "true"
    vault-allowed = "true"
  }
}

resource "aws_iam_policy" "caascad_administrator_operator_policy" {
  count = var.add_admin ? 1 : 0
  name = "caascad_administrator_operator"
  path = "/"

  policy = data.aws_iam_policy_document.caascad_administrator_operator_policy.json
}

resource "aws_iam_role_policy_attachment" "caascad_administrator_operator_policy" {
  count = var.add_admin ? 1 : 0
  role       = aws_iam_role.caascad_administrator_operator[count.index].name
  policy_arn = aws_iam_policy.caascad_administrator_operator_policy[count.index].arn
}
