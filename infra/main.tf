terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.27.0"
    }
  }

  cloud {
    organization = "dakual"
    workspaces {
      tags = ["todo"]
    }
  }

  required_version = ">= 1.3.6"
}

provider "aws" {
  region  = local.var.region
}

locals {
    workspace_path = "${path.module}/variables/${terraform.workspace}.yaml" 
    defaults       = file("${path.module}/variables/default.yaml")

    workspace = fileexists(local.workspace_path) ? file(local.workspace_path) : yamlencode({})
    var       = merge(
        yamldecode(local.defaults),
        yamldecode(local.workspace)
    )
}

module "iam" {
  source              = "./modules/iam"
  name                = local.var.name
  environment         = local.var.environment
}

module "r53" {
  source              = "./modules/r53"
  name                = local.var.name
  environment         = local.var.environment
  domain              = local.var.domain
  alb_zone_id         = module.alb.alb_zone_id
  alb_dns_name        = module.alb.alb_dns_name
}

module "rds" {
  source              = "./modules/rds"
  name                = local.var.name
  environment         = local.var.environment
  rds_security_groups = [ module.vpc.vpc_sg_rds ]
  rds_subnets         = module.vpc.vpc_public_subnets
}

module "vpc" {
  source              = "./modules/vpc"
  name                = local.var.name
  cidr                = local.var.cidr
  private_subnets     = local.var.private_subnets
  public_subnets      = local.var.public_subnets
  availability_zones  = local.var.availability_zones
  environment         = local.var.environment
}

# module "efs" {
#   source              = "./modules/efs"
#   name                = local.var.name
#   private_subnets     = module.vpc.vpc_private_subnets
#   vpc_id              = module.vpc.vpc_id
#   efs_sg              = [ module.vpc.vpc_sg_efs ]
#   environment         = local.var.environment
# }

module "alb" {
  source              = "./modules/alb"
  name                = local.var.name
  vpc_id              = module.vpc.vpc_id
  subnets             = module.vpc.vpc_public_subnets
  environment         = local.var.environment
  alb_security_groups = [ module.vpc.vpc_sg_alb ]
  alb_tls_cert_arn    = module.r53.r53_tls_certificate
}

module "ecs" {
  source              = "./modules/ecs-cluster"
  name                = local.var.name
  environment         = local.var.environment
}

#########################################################
# FRONTEND
#########################################################

module "frontend-task" {
  source              = "./modules/ecs-task"
  name                = local.var.name
  environment         = local.var.environment
  region              = local.var.region
  app                 = local.var.apps.frontend
  subnets             = module.vpc.vpc_private_subnets
  ecs_cluster_name    = module.ecs.ecs_name
  ecs_cluster_id      = module.ecs.ecs_id
  ecs_log_group       = module.ecs.ecs_log_group
  ecs_task_sg         = [ module.vpc.vpc_sg_ecs ]
  ecs_task_role       = module.iam.ecs_task_execution_role_arn
  alb_tg_arn          = module.alb.alb_tg_arn
  container_env       = []
}

module "frontend-ecr" {
  source              = "./modules/ecr"
  name                = local.var.name
  environment         = local.var.environment
  app                 = local.var.apps.frontend
}

#########################################################
# BACKEND
#########################################################

module "backend-task" {
  source              = "./modules/ecs-task"
  name                = local.var.name
  environment         = local.var.environment
  region              = local.var.region
  app                 = local.var.apps.backend
  subnets             = module.vpc.vpc_private_subnets
  ecs_cluster_name    = module.ecs.ecs_name
  ecs_cluster_id      = module.ecs.ecs_id
  ecs_log_group       = module.ecs.ecs_log_group
  ecs_task_sg         = [ module.vpc.vpc_sg_ecs ]
  ecs_task_role       = module.iam.ecs_task_execution_role_arn
  alb_tg_arn          = module.backend-alb.alb_tg_arn
  container_env       = [{
      name  = "DB_HOST"
      value = module.rds.mysql.DB_HOST
    },{
      name  = "DB_PORT"
      value = module.rds.mysql.BD_PORT
    },{
      name  = "DB_NAME"
      value = module.rds.mysql.DB_NAME
    },{
      name  = "DB_USER"
      value = module.rds.mysql.DB_USER
    },{
      name  = "DB_PASS"
      value = module.rds.mysql.DB_PASS
  }]
}

module "backend-ecr" {
  source              = "./modules/ecr"
  name                = local.var.name
  environment         = local.var.environment
  app                 = local.var.apps.backend
}

module "backend-alb" {
  source              = "./modules/alb"
  name                = local.var.apps.backend.name
  vpc_id              = module.vpc.vpc_id
  subnets             = module.vpc.vpc_public_subnets
  environment         = local.var.environment
  alb_security_groups = [ module.vpc.vpc_sg_alb ]
  alb_tls_cert_arn    = module.r53.r53_tls_certificate
}

resource "aws_route53_record" "api" {
  zone_id = module.r53.r53_zone_id
  name    = local.var.environment == "prd" ? "api" : "api-${local.var.environment}"
  type    = "A"

  alias {
    name                   = module.backend-alb.alb_dns_name
    zone_id                = module.backend-alb.alb_zone_id
    evaluate_target_health = true
  }
}
