variable aws_region {
  type        = string
  default     = "eu-west-3"
  description = "AWS Region"
}

variable caascad_operator_trusted_arn {
  type        = string
  description = "ARN that is allowed to assume the `caascad-operator` role."
}
