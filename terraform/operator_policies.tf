data aws_iam_policy_document caascad_operator_base_policy {

  // Needed to start EKS cluster
  statement {
    actions = [
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
    ]
    resources = [
      "*",
      # FIXME: this should work
      # aws_iam_role.eks_cluster_role.arn,
      # aws_iam_role.eks_node_group_role.arn,
      # // Allow to check for SLR AWSServiceRoleForAmazonEKSNodegroup
      # "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/*",
    ]
  }

  // Allow to create SLR for node group
  statement {
    actions = [
      "iam:CreateServiceLinkedRole",
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values = [
        "eks.amazonaws.com",
        "eks-nodegroup.amazonaws.com",
      ]
    }
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
      // authorize creating requests in AWS support
      "support:*",
    ]
    resources = [
      "*"
    ]
  }

  // Authorize creation of EC2|Autoscaling|Cloudwatch resources if they have the caascad-managed tag
  statement {
    actions = [
      "ec2:*",
      "autoscaling:*",
      "cloudwatch:*"
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
      "*"
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

  // Authorize actions on EC2|Autoscaling|Cloudwatch resources only if the tag caascad-managed is set
  statement {
    actions = [
      "ec2:*",
      "autoscaling:*",
      "cloudwatch:*"
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

data aws_iam_policy_document caascad_operator_create_cluster_policy {
 // Authorize EKS actions on caascad clusters and node groups
  statement {
    actions = [
      "eks:*",
    ]
    resources = [
      "arn:aws:eks:*:${data.aws_caller_identity.current.account_id}:cluster/caascad-*",
      "arn:aws:eks:*:${data.aws_caller_identity.current.account_id}:nodegroup/caascad-*",
    ]
  }
}

// Case of existing VPC and EKS cluster
data aws_iam_policy_document caascad_operator_existing_eks_policy {
  // Authorize EKS actions on allowed clusters
  statement {
    actions = [
      "eks:CreateNodeGroup",
    ]
    resources = [
       "*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/caascad-allowed"
      values   = ["true"]
    }
  }

  // Authorize EKS actions on allowed nodegroups/caascad-managed resources
  statement {
    actions = [
      "eks:DeleteNodeGroup",
      "eks:UpdateNodegroupConfig",
      "eks:UpdateNodegroupVersion",
      "eks:TagResource",
      "eks:UnTagResource",
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

  // Authorize SecurityGroup creation on allowed VPC. (bastion)
  statement {
    actions = [
      "ec2:CreateSecurityGroup",
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/caascad-allowed"
      values   = ["true"]
    }
  }
}