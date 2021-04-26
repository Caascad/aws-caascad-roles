resource aws_iam_role eks_cluster_role {
  name                  = "caascad-eks-cluster-role"
  force_detach_policies = true

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = {
    caascad = "true"
  }

}

// https://medium.com/faun/aws-eks-the-role-is-not-authorized-to-perform-ec2-describeaccountattributes-error-1c6474781b84
data aws_iam_policy_document eks_cluster_role_custom {
  statement {
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeInternetGateways",
    ]
    resources = [
      "*",
    ]
  }
}

resource aws_iam_policy eks_cluster_role_custom {
  name = "caascad-eks-cluster-policy"
  path = "/"

  policy = data.aws_iam_policy_document.eks_cluster_role_custom.json
}

resource aws_iam_role_policy_attachment eks_cluster {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource aws_iam_role_policy_attachment eks_cluster_slr {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource aws_iam_role_policy_attachment eks_cluster_custom {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = aws_iam_policy.eks_cluster_role_custom.arn
}
