output "ecs_cluster" {
  value     = module.ecs.ecs_name
}

output "rds_mysql" {
  value     = module.rds.mysql
  sensitive = true
}

output "alb_main" {
  value     = module.alb.alb_dns_name
}

output "alb_backend" {
  value     = module.backend-alb.alb_dns_name
}

output "backend_url" {
  value     = aws_route53_record.api.fqdn
}

output "main_url" {
  value     = module.r53.main_fqdn
}

output "ecr_frontend" {
  value     = module.backend-ecr.aws_ecr_repository_url
}

output "ecr_backend" {
  value     = module.backend-ecr.aws_ecr_repository_url
}