variable caascad_operator_trusted_arn {
  type        = string
  description = "ARN that is allowed to assume the `caascad-operator` role."
}

variable existing_cluster {
  type        = bool
  default     = false
  description = "Indicate if the EKS cluster and so the required network (VPC, subnets, ...) is already existing."
}
