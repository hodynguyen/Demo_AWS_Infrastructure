module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  # ------------------------
  # Cluster settings
  # ------------------------
  cluster_name    = "acme-eks"
  cluster_version = "1.29"

  # Endpoint settings
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  # ------------------------
  # Networking
  # ------------------------
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # ------------------------
  # IAM / Security
  # ------------------------
  enable_irsa = true

  # ------------------------
  # Node Group (EC2 workers)
  # ------------------------
  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]

      desired_size = 2
      min_size     = 2
      max_size     = 4

      subnet_ids = var.private_subnet_ids

      tags = {
        "k8s.io/cluster-autoscaler/enabled"   = "true"
        "k8s.io/cluster-autoscaler/acme-eks" = "owned"
      }
    }
  }

  # ------------------------
  # Default add-ons (required)
  # ------------------------
  cluster_addons = {
    coredns = { resolve_conflicts = "OVERWRITE" }
    kube-proxy = { resolve_conflicts = "OVERWRITE" }
    vpc-cni = { resolve_conflicts = "OVERWRITE" }
  }

  tags = {
    Environment = "prod"
    Project     = "acme"
  }
}
