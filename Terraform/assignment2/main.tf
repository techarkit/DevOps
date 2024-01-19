provider "aws" {
        region = "us-east-2"
        secret_key = var.secret
        access_key = var.access
}
resource "aws_instance" "Ins2" {
        ami = "ami-05fb0b8c1424f266b"
        instance_type = "t2.micro"
        key_name = "keypair_ravi"
        tags = {
                Name = "Assignment-2"
        }
}
resource "aws_eip" "Elastic-IP" {
        vpc = true
}
resource "aws_eip_association" "ElasticIP-Assocn" {
  instance_id   = aws_instance.Ins2.id
  allocation_id = aws_eip.Elastic-IP.id
}
