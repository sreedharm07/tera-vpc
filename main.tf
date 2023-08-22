resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
}


module "subnets" {
  source = "./module"

  vpc_id   = aws_vpc.vpc.id
  for_each = var.subnets
  subnets  = each.value
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internot"
  }
}

output "subnets" {
  value = module.subnets
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
  tags          = {
    Name = "gw NAT"
  }
}

resource "aws_route" "ngw" {
count =  length(local.private_subnet_ids)
route_table_id         =element(local.private_route_ids,count.index )
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.example.*.id,count.index )
}
