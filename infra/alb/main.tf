locals {
  enabled = var.enable
}

# IAM policy recommended by AWS for the Load Balancer Controller
resource "aws_iam_policy" "controller" {
  count       = local.enabled ? 1 : 0
  name_prefix = "alb-controller-policy-"
  description = "Permissions for AWS Load Balancer Controller"
  policy      = file("${path.module}/policy.json")
}

# IRSA role mapped to kube-system/aws-load-balancer-controller
module "irsa" {
  count  = local.enabled ? 1 : 0
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name_prefix = "alb-controller-"

  attach_load_balancer_controller_policy = false
  policy_arns                            = [aws_iam_policy.controller[0].arn]

  oidc_providers = {
    eks = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

# AWS-managed EKS add-on for the controller (avoids Helm connectivity)
resource "aws_eks_addon" "alb" {
  count                  = local.enabled ? 1 : 0
  cluster_name           = var.cluster_name
  addon_name             = "aws-load-balancer-controller"
  addon_version          = "v2.8.3-eksbuild.1"
  resolve_conflicts      = "OVERWRITE"
  service_account_role_arn = module.irsa[0].iam_role_arn

  tags = {
    ManagedBy = "terraform"
    Feature   = "alb-controller"
  }
}

# Tag public subnets so the controller can discover them for ALB placement
resource "aws_ec2_tag" "public_subnet_elb" {
  for_each = local.enabled ? toset(var.public_subnet_ids) : []

  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "public_subnet_cluster_shared" {
  for_each = local.enabled ? toset(var.public_subnet_ids) : []

  resource_id = each.value
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

