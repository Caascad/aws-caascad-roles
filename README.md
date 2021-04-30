# aws-caascad-roles

This repository contains the definition of AWS IAM roles to create in AWS
accounts managed by Caascad.

Currently the roles must be provisioned with `terraform`.

## Terraform

The code is located in the [./terraform](./terraform) directory.

You can apply this code directly or you can use it as a `terraform` module in
your own provisioning.

### Installing terraform

The code is compatible with `terraform 0.12.X` series. You can find pre-built
binaries of `terraform` [here](https://releases.hashicorp.com/terraform/) or you
can install it using a package manager (depending of your system).

### Terraform state

`terraform` manage a state file which track the different resources that you
have created with `terraform`.

By default the state file is stored locally (local backend).

Multiple users can't manage the same `terraform` configuration if they don't
share the state between them.

If you need to share the state file between multiple users you need to
configure [explicitely some remote
backend](https://www.terraform.io/docs/backends/types).

You can add a file describing the `backend` you want to use in the `./terraform`
directory (for example in a file named `override.tf`).

### Initialize terraform

Once you have installed `terraform` and configured a backend,
go inside the `terraform` directory and run:

```sh
$ cd terraform
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "aws" (hashicorp/aws) 3.19.0...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

`terraform` will automatically download the AWS provider.

### AWS credentials

To `apply` or `plan` the `terraform` configuration you need to provide AWS
credentials to the AWS `terraform` provider.

Multiple options are available to do this. See the [documentation of the AWS
provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
for more information.

We describe below two simple methods for providing AWS credentials to `terraform`.

The credentials you provide must have rights to create roles, policies in AWS IAM.

#### Environment variables

You can simply expose `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` environment
variables and the `terraform` AWS provider will use them automatically.

#### AWS credentials file

If you already have an [aws credentials
file](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
you can instruct `terraform` to use it.

In your `override.tf` file you can add:

```tf
provider aws {
    region  = "eu-west-3"
    profile = "<profile_name>"
}
```

Where `<profile_name>` is the name of some profile in your aws credentials
file.

By default `terraform` will look at `$HOME/.aws/credentials` or
`"%USERPROFILE%\.aws\credentials"` to find the credentials file.

### Configuring inputs

This `terraform` configuration needs only one `input`:

* `caascad_operator_trusted_arn`: some IAM ARN will be be provided to you by Caascad.
* `existing_cluster`: indicate if the EKS cluster is already existing and will not be managed by Caascad (default is `false`). In this case, you will need to add a tag named `caascad-allowed` with value `true` to the VPC and the EKS cluster.

Once you have received the ARN from the Caascad team create a file named `terraform.tfvars`
in the `./terraform` directory with the following content:

```tf
caascad_operator_trusted_arn = "<ARN>"
```

Where `<ARN>` is the AWS IAM ARN provided by the Caascad team.

### Planning terraform changes

Before trying to `apply` the configuration you can run a `plan` that will show
you what will be provisioned on your AWS account:

```sh
$ terraform plan
...
```

If all goes well you can run `apply`:

```sh
$ terraform apply
...
```

After the `apply` command is complete you should see some `outputs`.

You need to communicate back to the Caascad team the value of the
`caascad_operator_role_arn` output.
