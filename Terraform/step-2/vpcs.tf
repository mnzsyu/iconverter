resource "aws_vpc" "dev-vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "dev-vpc"
  }
}

resource "aws_vpc" "prod-vpc" {
  cidr_block       = "10.1.0.0/16"

  tags = {
    Name = "prod-vpc"
  }
}

data "aws_availability_zones" "available_zones" {
  state = "available"
}
