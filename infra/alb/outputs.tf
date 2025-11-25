output "alb_controller_role_arn" {
  description = "IAM role used by the AWS Load Balancer Controller service account"
  value       = local.enabled && length(module.irsa) > 0 ? module.irsa[0].iam_role_arn : null
}

output "alb_controller_policy_arn" {
  description = "IAM policy attached to the controller service account"
  value       = local.enabled && length(aws_iam_policy.controller) > 0 ? aws_iam_policy.controller[0].arn : null
}

