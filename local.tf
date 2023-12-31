locals {

  public_subnets     = [for k, v in lookup(lookup(module.subnets, "public", null), "subnets", null) :v.id]
  app_subnets        = [for k, v in lookup(lookup(module.subnets, "app", null), "subnets", null) :v.id]
  db_subnets         = [for k, v in lookup(lookup(module.subnets, "db", null), "subnets", null) :v.id]
  private_subnet_ids = concat(local.app_subnets, local.db_subnets)


  public_routs      = [for k, v in lookup(lookup(module.subnets, "public", null), "route_table", null) :v.id]
  app_routs         = [for k, v in lookup(lookup(module.subnets, "app", null), "route_table", null) :v.id]
  db_routs          = [for k, v in lookup(lookup(module.subnets, "db", null), "route_table", null) :v.id]
  private_route_ids = concat(local.app_routs, local.db_routs)


  tags= merge(var.tags,{tf-module-Name="vpc"},{env =var.env}  )
}

