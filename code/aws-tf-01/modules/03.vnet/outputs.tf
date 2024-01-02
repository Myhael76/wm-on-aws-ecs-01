output "Main-VPC-id" {
  description = "Identifier for the main VPC"
  value       = aws_vpc.service-vpc-01.id
}

# Our services will be associated to the private subnet(s)
output "ecs_service_subnet_ids" {
  description = "Defined subnets ids list"
  value       = [aws_subnet.private.id]
}

output "ecs_service_security_group_ids" {
  description = "Defined security groups ids list"
  #value = aws_default_security_group.vpc-01-sg-01
  value = [aws_security_group.vpc-01-sg-01.id]
}
