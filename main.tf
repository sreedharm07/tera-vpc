resource "aws_vpc" "main" {
  cidr_block = var.cidr
}

module "subnet" {
  source = "./subnets"
  vpc_id =aws_vpc.main.id
  for_each = var.subnets
  subnets= each.value
}

