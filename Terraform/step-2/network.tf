resource "aws_subnet" "dev-subnet-public" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.dev-vpc.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.dev-vpc.id
  map_public_ip_on_launch = true
}

resource "aws_subnet" "dev-subnet-private" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.dev-vpc.cidr_block, 8, 4 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.dev-vpc.id
}

resource "aws_subnet" "prod-subnet-public" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.prod-vpc.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.prod-vpc.id
  map_public_ip_on_launch = true
}

resource "aws_subnet" "prod-subnet-private" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.prod-vpc.cidr_block, 8, 4 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.prod-vpc.id
}

resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "prod-igw"
  }
}

resource "aws_route" "dev-route" {
  route_table_id         = aws_vpc.dev-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev-igw.id
}

resource "aws_route" "prod-route" {
  route_table_id         = aws_vpc.prod-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.prod-igw.id
}

resource "aws_eip" "dev-nat-eip" {
  count      = 2
  vpc        = true
  depends_on = [aws_internet_gateway.dev-igw]
}

resource "aws_eip" "prod-nat-eip" {
  count      = 2
  vpc        = true
  depends_on = [aws_internet_gateway.prod-igw]
}

resource "aws_nat_gateway" "dev-nat" {
  count         = 2
  subnet_id     = element(aws_subnet.dev-subnet-public.*.id, count.index)
  allocation_id = element(aws_eip.dev-nat-eip.*.id, count.index)
}

resource "aws_nat_gateway" "prod-nat" {
  count         = 2
  subnet_id     = element(aws_subnet.prod-subnet-public.*.id, count.index)
  allocation_id = element(aws_eip.prod-nat-eip.*.id, count.index)
}

resource "aws_route_table" "dev-rt" {
  count  = 2
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.dev-nat.*.id, count.index)
  }
}

resource "aws_route_table" "prod-rt" {
  count  = 2
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.prod-nat.*.id, count.index)
  }
}

resource "aws_route_table_association" "dev-rta" {
  count          = 2
  subnet_id      = element(aws_subnet.dev-subnet-private.*.id, count.index)
  route_table_id = element(aws_route_table.dev-rt.*.id, count.index)
}

resource "aws_route_table_association" "prod-rta" {
  count          = 2
  subnet_id      = element(aws_subnet.prod-subnet-private.*.id, count.index)
  route_table_id = element(aws_route_table.prod-rt.*.id, count.index)
}

resource "aws_security_group" "dev-lb-sg" {
  vpc_id = aws_vpc.dev-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-lb-sg"
  }
}

resource "aws_security_group" "prod-lb-sg" {
  vpc_id = aws_vpc.prod-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "prod-lb-sg"
  }
}

resource "aws_security_group" "dev-app-sg" {
  vpc_id = aws_vpc.dev-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [ aws_security_group.dev-lb-sg.id ]
  }

  tags = {
    Name = "dev-app-sg"
  }

  depends_on = [aws_lb.dev-lb]
}

resource "aws_security_group" "prod-app-sg" {
  vpc_id = aws_vpc.prod-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [ aws_security_group.prod-lb-sg.id ]
  }

  tags = {
    Name = "prod-app-sg"
  }

  depends_on = [aws_lb.prod-lb]
}