resource "aws_vpc" "the_cool_ai_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "TheCoolAIVPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.the_cool_ai_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.the_cool_ai_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "PrivateSubnet"
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

resource "aws_route_table_association" "public_subnet_rt_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
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
  name            = "the-cool-ai-alb"
  internal        = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets         = [aws_subnet.public_subnet.id]

  tags = {
    Name = "TheCoolAIALB"
  }
}

resource "aws_alb_target_group" "the_cool_ai_tg" {
  name     = "the-cool-ai-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.the_cool_ai_vpc.id

  health_check {
    path                = "/health"
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
