resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
}


module "subnet" {
  source = "./module"
  for_each = var.subnets
  subnets=each.value
  vpc_id= aws_vpc.vpc.id
}
