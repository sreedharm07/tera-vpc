resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
tags = merge(local.tags, { Name= "${var.env}-vpc"})
}


module "subnets" {
  source = "./module"

  vpc_id   = aws_vpc.vpc.id
  for_each = var.subnets
  subnets  = each.value
  tags = local.tags
  env=var.env
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.tags,{Name= "${var.env}-igw"})
}

resource "aws_route" "igw" {
  for_each               =lookup(lookup(module.subnets,"public",null),"route_table",null)
  route_table_id         =each.value["id"]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_eip" "lb" {
  count = length(local.public_subnets)
  domain   = "vpc"
}

resource "aws_nat_gateway" "example" {
  count = length(local.public_subnets)
  allocation_id = element(aws_eip.lb.*.id,count.index )
  subnet_id     = element(local.public_subnets,count.index )
  tags   = merge(local.tags,  {Name=  "${var.env}-natgate"})
 }


resource "aws_route" "ngw" {
count =  length(local.private_subnet_ids)
route_table_id         =element(local.private_route_ids,count.index )
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.example.*.id,count.index )
}


resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id   = aws_vpc.vpc.id
  vpc_id        = var.default_vpc_id
  auto_accept = true
  tags =merge(local.tags , {Name = "${var.env}-peering"})
}

resource "aws_route" "to_default" {
  count                     = length(local.private_subnet_ids)
  route_table_id            = element(local.private_route_ids, count.index )
  destination_cidr_block    = var.default_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "to_private_vpc" {
  route_table_id            = var.vpc_default_id
  destination_cidr_block    = var.cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

