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

resource "aws_route" "igw" {
  for_each       = lookup(lookup(module.subnets, "public", null), "route", null)
  route_table_id = lookup(each.value, "id", null)
  gateway_id     = aws_internet_gateway.igw.id
}