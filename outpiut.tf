output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet" {
  value = module.subnets
}
output "public_subnet-ids" {
  value = local.public_subnets
}