<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| aws | >= 3.8.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.8.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_region | AWS Region | `string` | `"eu-west-3"` | no |
| caascad\_operator\_trusted\_arn | ARN that is allowed to assume the `caascad-operator` role. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| caascad\_operator\_role\_arn | Role ARN used for Caascad provisioning and lifecycle |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
