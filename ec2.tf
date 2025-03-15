provider "aws" {
  region = "us-east-1" # Change as needed
}

resource "aws_key_pair" "builder_key" {
  key_name   = "builder-key"
  public_key = tls_private_key.builder.public_key_openssh
}

resource "tls_private_key" "builder" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_security_group" "builder_sg" {
  name        = "builder-sg"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2instance" {
  ami           = "ami-0c55b159cbfafe1f0" # Change this to a valid AMI ID
  instance_type = "t2.micro"
  key_name      = aws_key_pair.builder_key.key_name
  security_groups = [aws_security_group.builder_sg.name]

  tags = {
    Name = "builder"
  }
}

output "private_key_pem" {
  value     = tls_private_key.builder.private_key_pem
  sensitive = true
}

output "public_ip" {
  value = aws_instance.ec2instance.public_ip
}
