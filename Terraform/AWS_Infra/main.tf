provider "aws" {
  region = "us-east-2"
  secret_key = var.secret
  access_key = var.access
}

resource "aws_vpc" "public_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "public_igw" {
  vpc_id = aws_vpc.public_vpc.id
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.public_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.public_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_igw.id
  }
}

resource "aws_route_table_association" "public_route_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_instance" "public_vm" {
  count         = 3
  ami           = "ami-05fb0b8c1424f266b"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = "CHANGE_KEY_PAIR"
  
   tags = {
     Name = "PublicVM-${count.index + 1}"
  }
}
