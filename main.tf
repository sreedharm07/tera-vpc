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
}

resource "aws_route" "igw" {
for_each =  lookup(lookup(module.subnets,"public",null),"route",null)
  route_table_id            = each.value["id"]
  destination_cidr_block    = "0.0.0.0/0"
 gateway_id =  aws_internet_gateway.igw.id
}

resource "aws_eip" "ngw" {
  for_each = lookup(lookup(module.subnets,"public",null),"route",null)
  domain   = "vpc"
}

resource "aws_nat_gateway" "example" {
  for_each = lookup(lookup(module.subnets,"public",null),"subnets",null)
  allocation_id = lookup(lookup(aws_eip.ngw,each.key,null),"id" ,null)
  subnet_id     = each.value["id"]

  tags = {
    Name = each.key
  }
}