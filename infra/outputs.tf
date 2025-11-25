output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_ca" {
  value = module.eks.cluster_certificate_authority_data
}

output "alb_controller_role_arn" {
  value       = module.alb_controller.alb_controller_role_arn
  description = "IAM role assumed by the ALB controller service account (null when disabled)"
}
