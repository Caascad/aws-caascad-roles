data aws_caller_identity current {}

resource aws_iam_role eks_cluster_role {
  name                  = "caascad_eks_cluster_role"
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

resource aws_iam_role_policy_attachment eks_cluster {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource aws_iam_role_policy_attachment eks_cluster_slr {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource aws_iam_role eks_node_group_role {
  name = "caascad_eks_node_group_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    caascad = "true"
  }
}

resource aws_iam_role_policy_attachment eks_worker_node {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource aws_iam_role_policy_attachment eks_cni {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource aws_iam_role_policy_attachment ec2_container_registry_ro {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

data aws_iam_policy_document caascad_provisioner_assumerole_policy {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.caascad_provisioner_user_arn]
    }
  }
}

data aws_iam_policy_document caascad_provisioner_policy {

  // Needed to start EKS cluster
  statement {
    actions = [
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
    ]
    resources = [
      aws_iam_role.eks_cluster_role.arn,
      aws_iam_role.eks_node_group_role.arn,
      // Allow to check for SLR AWSServiceRoleForAmazonEKSNodegroup
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/*",
    ]
  }

  statement {
    actions = [
      "eks:Describe*",
      "eks:List*",
    ]
    resources = [
      "*"
    ]
  }

  // Authorize EKS actions on caascad clusters and node groups
  statement {
    actions = [
      "eks:*",
    ]
    resources = [
      "arn:aws:eks:*:${data.aws_caller_identity.current.account_id}:cluster/caascad-*",
      "arn:aws:eks:*:${data.aws_caller_identity.current.account_id}:nodegroup/caascad-*",
      // TODO: remove
      "arn:aws:eks:*:${data.aws_caller_identity.current.account_id}:nodegroup/eks-caascad-*",
    ]
  }

  // Needed for EKS service
  statement {
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["eks.amazonaws.com"]
    }
  }

  // Theses can't be scoped with tags
  statement {
    actions = [
      "ec2:ImportKeyPair",
      // start instance
      "ec2:AllocateAddress",
      "ec2:AssociateAddress",
      // destroy instance
      "ec2:DisassociateAddress",
      "ec2:DetachNetworkInterface",
      // debug unauthorized sts calls
      "sts:DecodeAuthorizationMessage",
    ]
    resources = [
      "*"
    ]
  }

  // Authorize creation if the resource contains the caascad-managed tag
  statement {
    actions = [
      "ec2:*",
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/caascad-managed"
      values   = ["true"]
    }
  }

  // When using RunInstances AWS will create automatically some resources
  // such as the default network interface.
  statement {
    actions = [
      "ec2:RunInstances",
    ]
    resources = [
      "arn:aws:ec2:*::image/*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:network-interface/*",
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:volume/*",
    ]
  }

  // When RunInstances creates dependent resources it will apply the same tags
  // that are set on the instance itself
  statement {
    actions = [
      "ec2:CreateTags"
    ]
    resources = [
      "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:*"
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["RunInstances"]
    }
  }

  // Authorize actions on EC2 resources only if the tag caascad-managed is set
  statement {
    actions = [
      "ec2:*"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/caascad-managed"
      values   = ["true"]
    }
  }

}

resource aws_iam_policy caascad_provisioner_policy {
  name = "caascad_provisioner"
  path = "/"

  policy = data.aws_iam_policy_document.caascad_provisioner_policy.json
}

resource aws_iam_role caascad_provisioner {
  name        = "caascad_provisioner"
  description = "Role used for Caascad provisioning and lifecycle"

  force_detach_policies = true

  assume_role_policy = data.aws_iam_policy_document.caascad_provisioner_assumerole_policy.json

  tags = {
    caascad       = "true"
    vault-allowed = "true"
  }

}

resource aws_iam_role_policy_attachment caascad_provisioner {
  role       = aws_iam_role.caascad_provisioner.name
  policy_arn = aws_iam_policy.caascad_provisioner_policy.arn
}

resource aws_iam_role_policy_attachment ec2_readonly {
  role       = aws_iam_role.caascad_provisioner.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}
