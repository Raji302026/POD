terraform {
  required_version = ">= 1.5.0"
}

module "dev" {
  source      = "../terraform-modules/app"
  app_name    = "robility"
  environment = "dev"
}

module "production" {
  source      = "../terraform-modules/app"
  app_name    = "robility"
  environment = "prod"
}

output "dev_id" {
  value = module.dev.app_id
}

output "prod_id" {
  value = module.production.app_id
}

moved {
  from = module.prod
  to   = module.production
}
