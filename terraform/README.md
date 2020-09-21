<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_region | AWS Region | `string` | `"eu-west-3"` | no |
| caascad\_provisioner\_user\_arn | User ARN that is allowed to assume the `caascad_provisioner` role. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| caascad\_provisioner\_role\_arn | Role ARN used for Caascad provisioning and lifecycle |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
