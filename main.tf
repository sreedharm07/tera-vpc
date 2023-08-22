resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
}


module "subnets" {
  source = "./module"

  vpc_id   = aws_vpc.vpc.id
  for_each = var.subnets
  subnets  = each.value
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internot"
  }
}

resource "aws_route" "r" {
  route_table_id            = "rtb-4fbb3ac4"
  destination_cidr_block    = "10.0.1.0/22"
  vpc_peering_connection_id = "pcx-45ff3dc1"
  depends_on                = [aws_route_table.testing]
}