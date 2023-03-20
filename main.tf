locals {
  tags_identity_provider = {
    "Name"        = "${var.role_name}-oidc"
    "tf-provider" = "${var.role_name}-oidc"
    "tf-ou"       = var.ou_name
  }

  tags_role = {
    "Name"    = "var.role_name"
    "tf-role" = "var.role_name"
    "tf-ou"   = var.ou_name
  }
}

resource "aws_iam_openid_connect_provider" "create_oidc_identity_provider" {
  url             = var.oidc_url
  client_id_list  = var.oidc_client_id_list
  thumbprint_list = var.oidc_thumbprint_list
  tags            = merge(var.tags_provider, var.use_tags_default ? local.tags_identity_provider : {})
}

data "aws_iam_policy_document" "create_main_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    dynamic "principals" {
      for_each = concat([
        {
          type        = "Federated"
          identifiers = [aws_iam_openid_connect_provider.create_oidc_identity_provider.arn]
        }
        ], var.oidc_main_policy.principals != null ? [for item in var.oidc_main_policy.principals != null ? var.oidc_main_policy.principals : [] : {
          type        = item.type
          identifiers = item.identifiers != null ? item.identifiers : [aws_iam_openid_connect_provider.create_oidc_identity_provider.arn]
      }] : [])
      iterator = item

      content {
        type        = item.value.type
        identifiers = item.value.identifiers
      }
    }

    dynamic "condition" {
      for_each = var.oidc_main_policy.conditions
      iterator = item

      content {
        test     = item.value.test
        variable = item.value.variable
        values   = item.value.values
      }
    }
  }
}

resource "aws_iam_role" "create_iam_role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.create_main_policy_document.json

  description          = var.role_description
  managed_policy_arns  = var.role_policy_arns
  max_session_duration = var.role_max_session_duration
  path                 = var.role_path
  permissions_boundary = var.role_permissions_boundary
  tags            = merge(var.tags_role, var.use_tags_default ? local.tags_role : {})
}

resource "aws_iam_policy" "create_custom_policies" {
  count = length(var.custom_policies)

  name        = try(var.custom_policies[count.index].name, null)
  path        = try(var.custom_policies[count.index].path, null)
  description = try(var.custom_policies[count.index].description, null)
  policy      = try(jsonencode(var.custom_policies[count.index].policy), null)
  tags        = try(var.custom_policies[count.index].tags, {})
}

resource "aws_iam_role_policy_attachment" "create_attach_custom_policies_on_role" {
  count = length(aws_iam_policy.create_custom_policies)

  policy_arn = aws_iam_policy.create_custom_policies[count.index].arn
  role       = aws_iam_role.create_iam_role.name
}
