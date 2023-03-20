# AWS IAM to create web identity provider for multiples accounts and regions with Terraform module
* This module simplifies creating and configuring of a IAM to create web identity provider across multiple accounts and regions on AWS

* Is possible use this module with one region using the standard profile or multi account and regions using multiple profiles setting in the modules.

## Actions necessary to use this module:

* Create file versions.tf with the exemple code below:
```hcl
terraform {
  required_version = ">= 1.1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.9"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}
```

* Criate file provider.tf with the exemple code below:
```hcl
provider "aws" {
  alias   = "alias_profile_a"
  region  = "us-east-1"
  profile = "my-profile"
}

provider "aws" {
  alias   = "alias_profile_b"
  region  = "us-east-2"
  profile = "my-profile"
}
```


## Features enable of IAM web identity provider configurations for this module:

- IAM role
- IAM identity provider
- Policies
- Attachments

## Usage exemples

### Creation IAM web identity provider with main policy to enable GitHub Actions and custom policies to S3 and EKS list

```hcl
module "web_identity_provider_git_hub" {
  source = "web-virtua-aws-multi-account-modules/iam-web-identity/aws"

  role_name            = "tf-github-actions-role"
  role_description     = "Role description"
  oidc_url             = "https://token.actions.githubusercontent.com"
  oidc_thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  oidc_main_policy = {
    conditions = [
      {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:aud"
        values   = ["sts.amazonaws.com"]
      },
      {
        test     = "StringLike"
        variable = "token.actions.githubusercontent.com:sub"
        values   = ["repo:lubysoftware/DUCO.WEB:*"]
      }
    ]
  }

  custom_policies = [
    {
      name        = "tf-s3-policy"
      description = "tf-s3-test-policy"

      policy = {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Action" : [
              "s3:ListAllMyBuckets"
            ],
            "Effect" : "Allow",
            "Resource" : "*"
          },
          {
            "Action" : [
              "s3:*"
            ],
            "Effect" : "Allow",
            "Resource" : "arn:aws:s3:::bucket-test"
          }
        ]

      }
    },
    {
      name        = "tf-eks-list-policy"
      path        = "/"
      description = "tf-eks-list-policy"

      policy = {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Action" : [
              "eks:ListNodegroups",
              "eks:DescribeFargateProfile",
              "eks:ListTagsForResource",
              "eks:ListAddons",
              "eks:DescribeAddon",
              "eks:ListFargateProfiles",
              "eks:DescribeNodegroup",
              "eks:DescribeIdentityProviderConfig",
              "eks:ListUpdates",
              "eks:DescribeUpdate",
              "eks:AccessKubernetesApi",
              "eks:DescribeCluster",
              "eks:ListClusters",
              "eks:DescribeAddonVersions",
              "eks:ListIdentityProviderConfigs",
              "ecr:DescribeImages"
            ],
            "Effect" : "Allow",
            "Resource" : "*"
          }
        ]

      }
    }
  ]

  providers = {
    aws = aws.alias_profile_b
  }
}
```

### Creation IAM web identity provider with main policy to enable GitHub Actions and adding second principal

```hcl
module "web_identity_provider_git_hub" {
  source = "web-virtua-aws-multi-account-modules/iam-web-identity/aws"

  role_name            = "tf-github-actions-role"
  role_description     = "Role description"
  oidc_url             = "https://token.actions.githubusercontent.com"
  oidc_thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  oidc_main_policy = {
    conditions = [
      {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:aud"
        values   = ["sts.amazonaws.com"]
      },
      {
        test     = "StringLike"
        variable = "token.actions.githubusercontent.com:sub"
        values   = ["repo:lubysoftware/DUCO.WEB:*"]
      }
    ]
    principals = [
      {
        type        = "Service"
        identifiers = ["firehose.amazonaws.com"]
      }
    ]
  }

  providers = {
    aws = aws.alias_profile_a
  }
}
```

## Variables

| Name | Type | Default | Required | Description | Options |
|------|-------------|------|---------|:--------:|:--------|
| role_name | `string` | `-` | yes | Role name | `-` |
| role_description | `string` | `null` | no | Role description | `-` |
| role_policy_arns | `list(string)` | `null` | no | Role managed policy ARNs | `-` |
| role_max_session_duration | `number` | `null` | no | Role max session duration | `-` |
| role_path | `string` | `null` | no | Role path | `-` |
| role_permissions_boundary | `string` | `null` | no | Role permissions boundary | `-` |
| custom_policies | `list(object)` | `[]` | no | List of the custom policies | `-` |
| oidc_url | `string` | `-` | yes | The URL of the identity provider. Corresponds to the iss claim" | `-` |
| oidc_thumbprint_list | `list(string)` | `-` | yes | A list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s) | `-` |
| oidc_main_policy | `list(object)` | `-` | yes | Conditions and additional principals to main policy to web identity provider | `-` |
| oidc_client_id_list | `list(string)` | `["sts.amazonaws.com"]` | no | A list of client IDs (also known as audiences). When a mobile or web app registers with an OpenID Connect provider, they establish a value that identifies the application. This is the value that's sent as the client_id parameter on OAuth requests | `-` |
| ou_name | `string` | `no` | no | Organization unit name | `-` |
| use_tags_default | `bool` | `true` | no | If true will be use the tags default" | `*`false <br> `*`true |
| tags_provider | `map(any)` | `{}` | no | Tags to identity provider | `-` |
| tags_role | `map(any)` | `{}` | no |Tags to role | `-` |


* Model of variable custom_policies
```hcl
variable "custom_policies" {
  description = "List of the custom policies"
  type = list(object({
    name        = string
    policy      = any
    path        = optional(string)
    description = optional(string)
    tags        = optional(any)
  }))
  default = [
    {
      name        = "tf-s3-policy"
      description = "tf-s3-test-policy"

      policy = {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Action" : [
              "s3:ListAllMyBuckets"
            ],
            "Effect" : "Allow",
            "Resource" : "*"
          },
          {
            "Action" : [
              "s3:*"
            ],
            "Effect" : "Allow",
            "Resource" : "arn:aws:s3:::luby-teste-lixo"
          }
        ]

      }
    }
  ]
}
```

* Model of variable oidc_main_policy
```hcl
variable "oidc_main_policy" {
  description = "Conditions and additional principals to main policy to web identity provider"
  type = object({
    conditions = list(object({
      test     = string
      variable = string
      values   = list(string)
    }))
    principals = optional(list(object({
      type        = string
      identifiers = optional(list(string))
    })))
  })
  default = {
    conditions = [
      {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:aud"
        values   = ["sts.amazonaws.com"]
      },
      {
        test     = "StringLike"
        variable = "token.actions.githubusercontent.com:sub"
        values   = ["repo:lubysoftware/DUCO.WEB:*"]
      }
    ]
    principals = [
      {
        type        = "Service"
        identifiers = ["firehose.amazonaws.com"]
      }
    ]
  }
}
```


## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.create_oidc_identity_provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.create_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_policy.create_custom_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.create_attach_custom_policies_on_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |


## Outputs

| Name | Description |
|------|-------------|
| `oidc_identity_provider` | OIDC identity provider |
| `main_policy_document` | Main policy document |
| `iam_role` | IAM role |
| `custom_policies` | Custom policies |
