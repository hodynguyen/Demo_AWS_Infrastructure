module "vpc" {
  source = "./vpc"

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}

module "db" {
  source = "./db"

  private_subnet_ids   = module.vpc.private_subnet_ids
  db_security_group_id = module.vpc.db_sg_id
}

module "eks" {
  source = "./eks"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "alb_controller" {
  source = "./alb"

  enable                    = false # toggle to true when ready to deploy the controller
  cluster_name              = module.eks.cluster_name
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn
  region                    = var.region
  vpc_id                    = module.vpc.vpc_id
  public_subnet_ids         = module.vpc.public_subnet_ids
}

module "route53" {
  source = "./route53"

  # FAKE domain, replace with real one when available
  root_domain = "acme.com"   # FAKE VALUE
}


