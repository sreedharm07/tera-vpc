locals {
  public_subnet_ids= [for k ,v in lookup(lookup(module.subnets,"public", null ),"subnets",null) : v.id ]
  app_subnet_ids= [for k ,v in lookup(lookup(module.subnets,"app", null ),"subnets",null):v.id]
  db_subnet_ids=  [for k ,v in lookup(lookup(module.subnets,"db", null ),"subnets",null):v.id]
  private_subnet_ids= concat(local.app_subnet_ids, local.db_subnet_ids)

  public_route_ids= [for k ,v in lookup(lookup(module.subnets,"public", null ),"route",null) : v.id ]
  app_route_ids= [for k ,v in lookup(lookup(module.subnets,"app", null ),"route",null):v.id]
  db_route_ids=  [for k ,v in lookup(lookup(module.subnets,"db", null ),"route",null):v.id]
  private_route_ids= concat(local.app_route_ids, local.db_route_ids)
}