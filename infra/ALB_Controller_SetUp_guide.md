# ========================================================================
# Example: AWS Load Balancer Controller Deployment via Terraform
# PURPOSE: Documentation only — this code is NOT meant to be executed.
# ========================================================================
#
# Assumptions:
# - You are using terraform-aws-modules/eks/aws to provision your EKS cluster
# - The IAM Role for ALB Controller was created manually (via AWS Console or CLI)
# - OIDC provider & IRSA backend are already enabled by the EKS module
# - This example merely demonstrates *how* ALB Controller would be deployed
#
# ========================================================================


# --------------------------------------------------------
# 1. Example Kubernetes & Helm providers (not executed)
# --------------------------------------------------------
# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   token                  = data.aws_eks_cluster_auth.eks.token
# }
#
# data "aws_eks_cluster_auth" "eks" {
#   name = module.eks.cluster_name
# }
#
# provider "helm" {
#   kubernetes {
#     host                   = module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#     token                  = data.aws_eks_cluster_auth.eks.token
#   }
# }


# --------------------------------------------------------
# 2. Example IRSA-enabled ServiceAccount (documentation only)
# --------------------------------------------------------
# resource "kubernetes_service_account" "alb_sa" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = "<your-alb-controller-role-arn>"
#     }
#   }
# }


# --------------------------------------------------------
# 3. Example Helm deployment of ALB Controller (documentation only)
# --------------------------------------------------------
# resource "helm_release" "aws_load_balancer_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#
#   depends_on = [kubernetes_service_account.alb_sa]
#
#   set {
#     name  = "clusterName"
#     value = module.eks.cluster_name
#   }
#
#   set {
#     name  = "region"
#     value = "ap-southeast-1"
#   }
#
#   set {
#     name  = "vpcId"
#     value = module.vpc.vpc_id
#   }
#
#   set {
#     name  = "serviceAccount.create"
#     value = false
#   }
#
#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }
# }


# --------------------------------------------------------
# 4. Example subnet tagging (documentation only)
# --------------------------------------------------------
# resource "aws_ec2_tag" "public_subnet_elb" {
#   resource_id = "<public-subnet-id>"
#   key         = "kubernetes.io/role/elb"
#   value       = "1"
# }
#
# resource "aws_ec2_tag" "shared_tag" {
#   resource_id = "<public-subnet-id>"
#   key         = "kubernetes.io/cluster/${module.eks.cluster_name}"
#   value       = "shared"
# }

# ========================================================================
# END OF EXAMPLE (NOT FOR EXECUTION)
# ========================================================================
