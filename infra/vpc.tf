resource "aws_vpc" "the_cool_ai_vpc" {
  cidr_block = "10.0.0.0/16"

  instance_tenancy = "default"
  tags = {
    Name = "TheCoolAIVPC"
  }
}

resource "aws_subnet" "public_subnets" {
  count  = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.the_cool_ai_vpc.id
  cidr_block = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "PublicSubnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.the_cool_ai_vpc.id
  cidr_block = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "PrivateSubnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "the_cool_ai_igw" {
  vpc_id = aws_vpc.the_cool_ai_vpc.id

  tags = {
    Name = "TheCoolAIIGW"
  }
}

resource "aws_route_table" "rt_for_public" {
  vpc_id = aws_vpc.the_cool_ai_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.the_cool_ai_igw.id
  }

  tags = {
    Name = "TheCoolAIPublicRT"
  }
}

resource "aws_route_table_association" "public_subnets_rt_association" {
  count = length(var.public_subnet_cidrs)
  subnet_id = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.rt_for_public.id
}

resource "aws_security_group" "for_public_resources" {
  name = "the_cool_ai_sg_allowing_for_public_on_3000"
  vpc_id = aws_vpc.the_cool_ai_vpc.id
  description = "This is SG for model exposed publicly"

  ingress {
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TheCoolAIModelSG"
  }
}