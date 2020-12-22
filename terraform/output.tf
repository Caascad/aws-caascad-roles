output caascad_operator_role_arn {
  value       = aws_iam_role.caascad_operator.arn
  description = "Role ARN used for Caascad provisioning and lifecycle"
}
