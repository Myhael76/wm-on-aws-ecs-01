# Security rules for the networking part

# We need an internet gateway to access internet from our resources
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.service-vpc-01.id
  tags   = merge(local.vnet_chapter_tags, { Name = "internet gateway" })
}

# Outbound traffic will come from the public subnet towards the internet gateway
resource "aws_route_table" "public_egress" {
  vpc_id = aws_vpc.service-vpc-01.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}
# associate public_egress route table to public subnet
resource "aws_route_table_association" "public_egress" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_egress.id
}

# Traffic coming from the private gateway must pass into a nat gateway first, then the internet gateway
resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.ngw_ip.id
  subnet_id     = aws_subnet.public.id
  tags          = merge(local.vnet_chapter_tags, { Name = "NAT Gateway" })
}
# NAT Gateway must have a public ip
resource "aws_eip" "ngw_ip" {
  domain = "vpc"
  tags   = merge(local.vnet_chapter_tags, { Name = "NAT Gateway IP" })
}
# Private subnet outbound connections must go to the NAT Gateway
resource "aws_route_table" "private_egress" {
  vpc_id = aws_vpc.service-vpc-01.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw.id
  }
}
#associate private_egress route table to private subnet
resource "aws_route_table_association" "private_egress" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_egress.id
}

# Allow outbound connections from the public subnet to the internet via 443 port
resource "aws_security_group" "vpc-01-sg-01" {
  # checkov:skip=CKV2_AWS_5: False positive, this is associated to ECS services in another module.connection 
  # see https://github.com/bridgecrewio/checkov/issues/1203#issuecomment-1873836090

  name        = "vpc-01-sg-01"
  description = "Allow network communications"
  vpc_id      = aws_vpc.service-vpc-01.id

  # ingress {
  #   description = "SSH"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    description = "Allow outbound 443 port, usually used for https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.vnet_chapter_tags, { Name = "vpc-01-sg-01" })
}
