resource "aws_iam_role" "caascad_monitoring_cloud_services" {
  name        = "caascad-monitoring-cloud-services"
  description = "Role used for Caascad monitoring of native AWS services"

  force_detach_policies = true

  max_session_duration = 1 * 60 * 60 // 1h

  assume_role_policy = data.aws_iam_policy_document.caascad_operator_assumerole_policy.json

  tags = {
    caascad       = "true"
    vault-allowed = "true"
  }
}

data "aws_iam_policy_document" "caascad_cloudwatch_metrics_readonly_policy" {
  statement {
    actions = [
      "tag:GetResources",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData",
      "cloudwatch:ListMetrics"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "caascad_cloudwatch_metrics_readonly_policy" {
  name = "caascad-cloudwatch-metrics-readonly"
  path = "/"

  policy = data.aws_iam_policy_document.caascad_cloudwatch_metrics_readonly_policy.json
}

resource "aws_iam_role_policy_attachment" "caascad_monitoring_cloud_services" {
  role       = aws_iam_role.caascad_monitoring_cloud_services.name
  policy_arn = aws_iam_policy.caascad_cloudwatch_metrics_readonly_policy.arn
}
