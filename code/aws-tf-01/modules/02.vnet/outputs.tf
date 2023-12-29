output "Main-VPC-id" {
  description = "Identifier for the main VPC"
  value       = aws_vpc.service-vpc-01.id
}
