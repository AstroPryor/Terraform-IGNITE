resource "aws_vpc" "example" {
  cidr_block = "10.10.64.0/20"


  tags = {
    Name = "Astro - Atos"
  }
}

resource "aws_subnet" "public_subnet" {
  cidr_block        = "10.10.64.0/24"
  vpc_id            = aws_vpc.example.id
  availability_zone = "us-west-2a"
  tags = {
    Name = "Astro - Subnet - 1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  cidr_block        = "10.10.65.0/24"
  vpc_id            = aws_vpc.example.id
  availability_zone = "us-west-2b"
  tags = {
    Name = "Astro - Subnet - 2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.example.id
  tags = {
    Name = "Astro - IGW"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Astro - Public RT"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web" {
  name   = "astro-web-sg"
  vpc_id = aws_vpc.example.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Astro - Web SG"
  }
}