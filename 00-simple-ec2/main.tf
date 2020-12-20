terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}

resource "aws_instance" "pokemon_demo" {
  ami           = "ami-069302b967476d106"
  instance_type = "t3.micro"

  subnet_id                   = var.pokemon_subnet
  vpc_security_group_ids      = ["sg-0377cfcbc040a880c"]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/sh
    wget https://github.com/ciberado/pokemon/releases/download/stress/pokemon-0.0.4-SNAPSHOT.jar
    java -jar pokemon-0.0.4-SNAPSHOT.jar
  EOF

  tags = {
    Name    = "pokemon"
    Owner   = "ciberado"
    Project = "terraform-pokemon-demo"
  }
}
