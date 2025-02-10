resource "aws_vpc" "the_cool_ai_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "TheCoolAIVPC"
  }
}


resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.the_cool_ai_vpc.id
  cidr_block              = var.public_subnet_a_cidr
  availability_zone       = var.availability_zone_a 
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnetA"
  }
}


resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.the_cool_ai_vpc.id
  cidr_block              = var.public_subnet_b_cidr
  availability_zone       = var.availability_zone_b 
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnetB"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.the_cool_ai_vpc.id
  cidr_block        = var.private_subnet_a_cidr
  availability_zone = var.availability_zone_a

  tags = {
    Name = "PrivateSubnetA"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id = aws_vpc.the_cool_ai_vpc.id
  cidr_block = var.private_subnet_b_cidr
  availability_zone = var.availability_zone_b

  tags = {
    Name = "PrivateSubnetB"
  }
}

resource "aws_internet_gateway" "the_cool_ai_igw" {
  vpc_id = aws_vpc.the_cool_ai_vpc.id

  tags = {
    Name = "TheCoolAIIGW"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.the_cool_ai_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.the_cool_ai_igw.id
  }

  tags = {
    Name = "TheCoolAIPublicRT"
  }
}


resource "aws_route_table_association" "public_subnet_a_rt_association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_b_rt_association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    "Name" = "TheCoolAINATEIP"
  }
}

resource "aws_nat_gateway" "the_cool_ai_nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public_subnet_a.id

  tags = {
    "Name" = "TheCoolAINATGW"
  }

  depends_on = [aws_internet_gateway.the_cool_ai_igw]
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.the_cool_ai_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.the_cool_ai_nat_gw.id
  }

  tags = {
    Name = "TheCoolAIPrivateRT"
  }
}

resource "aws_route_table_association" "private_subnet_a_rt_association" {
  subnet_id = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_subnet_b_rt_association" {
  subnet_id = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt.id
}


resource "aws_security_group" "ecs_sg" {
  name        = "the_cool_ai_ecs_sg"
  vpc_id      = aws_vpc.the_cool_ai_vpc.id
  description = "Security group for ECS tasks"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TheCoolAIECSSG"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "the_cool_ai_alb_sg"
  vpc_id      = aws_vpc.the_cool_ai_vpc.id
  description = "Security group for ALB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "TheCoolAIALBSG"
  }
}
resource "aws_alb" "the_cool_ai_alb" {
  name               = "the-cool-ai-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]

  tags = {
    Name = "TheCoolAIALB"
  }
}

resource "aws_alb_target_group" "the_cool_ai_tg" {
  name     = "the-cool-ai-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.the_cool_ai_vpc.id
  target_type = "ip"

  health_check {
    path                = "/healthz"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "TheCoolAITG"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.the_cool_ai_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.the_cool_ai_tg.arn
  }
}
