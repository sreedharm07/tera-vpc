locals {

  public_subnets     = [for k, v in lookup(lookup(module.subnets, "public", null), "subnets", null) :v]
  app_subnets        = [for k, v in lookup(lookup(module.subnets, "app", null), "subnets", null) :v]
  db_subnets         = [for k, v in lookup(lookup(module.subnets, "db", null), "subnets", null) :v]
  private_subnet_ids = concat(local.app_subnets, local.db_subnets)


  public_routs      = [for k, v in lookup(lookup(module.subnets, "public", null), "routs", null) :v]
  app_routs         = [for k, v in lookup(lookup(module.subnets, "app", null), "routs", null) :v]
  db_routs          = [for k, v in lookup(lookup(module.subnets, "db", null), "routs", null) :v]
  private_route_ids = concat(local.app_routs, local.db_routs)
}