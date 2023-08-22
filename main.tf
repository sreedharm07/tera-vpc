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
count = length(local.public_subnet_ids)
domain   = "vpc"
}

resource "aws_nat_gateway" "nat" {
  count =  length(local.public_subnet_ids)
  allocation_id = element(aws_eip.id.*.id,count.index )
  subnet_id     = element(local.public_subnet_ids,count.index )
}

resource "aws_route" "ngw" {
  count = length(local.private_subnet_ids)
  route_table_id            = element(local.private_route_ids,count.index)
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = element(aws_nat_gateway.nat.*.id, count.index )
}


resource "aws_vpc_peering_connection" "foo" {
  peer_vpc_id   = aws_vpc.vpc.id
  vpc_id        = var.default_vpc
}
