provider "aws" {
        alias = "Ohio"
        region = "us-east-2"
        secret_key = var.secret
        access_key = var.access
}
provider "aws" {
        alias = "NV"
        region = "us-east-1"
        secret_key = var.secret
        access_key = var.access
}
resource "aws_instance" "Ins3-1" {
        provider = aws.Ohio
        ami = "ami-05fb0b8c1424f266b"
        instance_type = "t2.micro"
        key_name = "keypair_ravi"
        tags = {
                Name = "Hello-Ohio"
        }
}
resource "aws_instance" "Ins3-2" {
        provider = aws.NV
        ami = "ami-0c7217cdde317cfec"
        instance_type = "t2.micro"
        key_name = "MyKeyPair-Ravi"
        tags = {
                Name = "Hello-Virginia"
        }
}
