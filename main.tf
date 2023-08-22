resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
}

module "subnets" {
  source = "./module"
  vpc_id = aws_vpc.vpc.id

  for_each = var.subnets
  subnets=each.value
}

output "subnets" {
  value = module.subnets
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet_public"
  }
}

resource "aws_route" "igw" {
  for_each = lookup(lookup(module.subnets,"public",null),"route",null)
  route_table_id            =each.value["id"]
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_eip" "id" {
  for_each = lookup(lookup(module.subnets,"public",null),"subnets",null)
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat" {
  for_each = lookup(lookup(module.subnets,"public", null ),"subnets",null)
  allocation_id = lookup(lookup(aws_eip.id, each.key,null),"id",null)
  subnet_id     = each.value["id"]
}

resource "aws_route" "app" {
  for_each = lookup(lookup(module.subnets,"app",null),"route",null)
  route_table_id            =each.value["id"]
  destination_cidr_block    = "0.0.0.0/0"
#  gateway_id = lookup(lookup(aws_nat_gateway.nat.id,each.value,null),"id",null)
  gateway_id = lookup(aws_nat_gateway.nat[each.key],"id",null)
}

resource "aws_route" "db" {
  for_each = lookup(lookup(module.subnets,"db",null),"route",null)
  route_table_id            =each.value["id"]
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id =  lookup(aws_nat_gateway.nat[each.key],"id",null)
}

resource "aws_vpc_peering_connection" "foo" {
  peer_vpc_id   = aws_vpc.vpc.id
  vpc_id        = var.default_vpc
}

