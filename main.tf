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
