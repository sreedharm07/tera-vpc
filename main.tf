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
  for_each               = lookup(lookup(module.subnets,each.value,null ),"public",null)
  route_table_id         =lookup(lookup(each.key,"public" ,null ),"id",null)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}