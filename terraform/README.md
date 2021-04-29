<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12.0 |
| aws | >= 3.8.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.8.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| caascad\_operator\_trusted\_arn | ARN that is allowed to assume the `caascad-operator` role. | `string` | n/a | yes |
| existing\_cluster | Indicate if the EKS cluster is already existing. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| caascad\_operator\_role\_arn | Role ARN used for Caascad provisioning and lifecycle |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
