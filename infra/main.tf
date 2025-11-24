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

  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
}

