output "oidc_identity_provider" {
  description = "OIDC identity provider"
  value       = aws_iam_openid_connect_provider.create_oidc_identity_provider
}

output "main_policy_document" {
  description = "Main policy document"
  value       = data.aws_iam_policy_document.create_main_policy_document
}

output "iam_role" {
  description = "IAM role"
  value       = aws_iam_role.create_iam_role
}

output "custom_policies" {
  description = "Custom policies"
  value       = try(aws_iam_policy.create_custom_policies, null)
}
