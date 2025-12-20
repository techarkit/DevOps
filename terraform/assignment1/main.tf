provider "aws" {
        region = "us-east-2"
        secret_key = var.secret
        access_key = var.access
}
resource "aws_instance" "Ins1" {
        ami = "ami-05fb0b8c1424f266b"
        instance_type = "t2.micro"
        key_name = "keypair_ravi"
        tags = {
                Name = "Assignment-1"
        }
}
