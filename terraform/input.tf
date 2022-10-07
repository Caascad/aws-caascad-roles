variable "caascad_operator_trusted_arn" {
  type        = string
  description = "ARN that is allowed to assume the `caascad-operator` role."
}

variable "existing_cluster" {
  type        = bool
  default     = false
  description = "Indicate if the EKS cluster is already existing."
}

variable "add_admin" {
  type        = bool
  default     = false
  description = "Indicate if we want to add administrator role."
}
