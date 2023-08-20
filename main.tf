resource "aws_vpc" "main" {
  cidr_block = var.cidr
}

module "subnet" {
  source = "./subnets"
  for_each = var.subnets
  vpc_id =aws_vpc.main.id
  subnets= each.value
}