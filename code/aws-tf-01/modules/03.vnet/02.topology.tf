# Network topology - two subnets - public and private
# Note: our purpose is to have one private, 
# however, due to detailed needs such as pulling public images
# or ad-hoc administration access control
# we also foresee a public one

resource "aws_vpc" "service-vpc-01" {
  cidr_block = "10.0.0.0/16"
  tags       = merge(local.vnet_chapter_tags, { Name = "service vpc" })
}

# By default deny all traffic on pur VPC
resource "aws_default_security_group" "default_vpc-01-sg" {
  vpc_id = aws_vpc.service-vpc-01.id
  tags   = merge(local.vnet_chapter_tags, { Name = "default_vpc-01-sg" })
}

# Log what is happening in the vnet into our project's cloudWatch log destination
resource "aws_flow_log" "vpc-01-flow-log" {
  iam_role_arn    = var.log_iam_role_arn         # permissions for the flow log
  log_destination = var.cloudwatch_log_group_arn # cloud watch destination log group
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.service-vpc-01.id
  tags            = merge(local.vnet_chapter_tags, { Name = "vpc-01-flow-log" })
}

# Public subnet is needed for internet communication
resource "aws_subnet" "public" {
  # This subnet is intended as a "public" subnet according to AWS base concepts

  vpc_id     = aws_vpc.service-vpc-01.id
  cidr_block = "10.0.1.0/24"
  tags       = merge(local.vnet_chapter_tags, { Name = "public subnet" })
}

# Main Service subnet is private
resource "aws_subnet" "private" {
  # This subnet is intended as a "public" subnet according to AWS base concepts

  vpc_id     = aws_vpc.service-vpc-01.id
  cidr_block = "10.0.2.0/24"
  tags       = merge(local.vnet_chapter_tags, { Name = "private subnet" })
}
