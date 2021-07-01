data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "caascad_operator_assumerole_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.caascad_operator_trusted_arn]
    }
  }
}

resource "aws_iam_role" "caascad_operator" {
  name        = "caascad-operator"
  description = "Role used for Caascad provisioning and lifecycle"

  force_detach_policies = true

  max_session_duration = 10 * 60 * 60 // 10h

  assume_role_policy = data.aws_iam_policy_document.caascad_operator_assumerole_policy.json

  tags = {
    caascad       = "true"
    vault-allowed = "true"
  }
}

/////////////////////////////// Base policy //////////////////////////////////
resource "aws_iam_policy" "caascad_operator_base_policy" {
  name = "caascad_operator_base"
  path = "/"

  policy = data.aws_iam_policy_document.caascad_operator_base_policy.json
}

resource "aws_iam_role_policy_attachment" "caascad_operator_base_policy" {
  role       = aws_iam_role.caascad_operator.name
  policy_arn = aws_iam_policy.caascad_operator_base_policy.arn
}

/////////////////////////////// EC2 read only policy //////////////////////////////////
resource "aws_iam_role_policy_attachment" "ec2_readonly" {
  role       = aws_iam_role.caascad_operator.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

////////////////// Caascad Operator (create cluster and network) policy //////////////

resource "aws_iam_policy" "caascad_operator_create_cluster_policy" {
  count = var.existing_cluster ? 0 : 1

  name = "caascad_operator_create_cluster"
  path = "/"

  policy = data.aws_iam_policy_document.caascad_operator_create_cluster_policy.json
}

resource "aws_iam_role_policy_attachment" "caascad_operator_create_cluster_policy" {
  count = var.existing_cluster ? 0 : 1

  role       = aws_iam_role.caascad_operator.name
  policy_arn = aws_iam_policy.caascad_operator_create_cluster_policy[count.index].arn
}

////////////////// Caascad Operator (existing cluster and network) policy //////////////
resource "aws_iam_policy" "caascad_operator_existing_eks_policy" {
  count = var.existing_cluster ? 1 : 0

  name = "caascad_operator_existing_eks"
  path = "/"

  policy = data.aws_iam_policy_document.caascad_operator_existing_eks_policy.json
}

resource "aws_iam_role_policy_attachment" "caascad_operator_existing_eks_policy" {
  count = var.existing_cluster ? 1 : 0

  role       = aws_iam_role.caascad_operator.name
  policy_arn = aws_iam_policy.caascad_operator_existing_eks_policy[count.index].arn
}
