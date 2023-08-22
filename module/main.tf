resource "aws_subnet" "main" {
  for_each          = var.subnets
  vpc_id            = var.vpc
  cidr_block        = each.value["cidr"]
  availability_zone = each.value["az"]

  tags = {
    Name = each.key
  }
}

variable "vpc" {}
variable "subnets" {}