locals {
  asg_tags = merge({
    Layer : "computing"
  }, var.tags)
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] /* Ubuntu */

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

module "app_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.prefix}_app_sg"
  description = "Application security group"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule = "http-8080-tcp"
      source_security_group_id = module.lb_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules        = ["all-all"]
}

resource "aws_launch_template" "app_launch_template" {
  name = "${var.prefix}_launch_template"
  
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 8
    }
  }

  credit_specification {
    cpu_credits = "standard"
  }

  ebs_optimized = true

  iam_instance_profile {
    name = "test"
  }

  image_id = data.aws_ami.ubuntu.id

  instance_initiated_shutdown_behavior = "terminate"

  instance_market_options {
    market_type = "spot"
  }

  instance_type = "t3.micro"

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = false
  }

  vpc_security_group_ids = [module.app_sg.security_group_id]

  tag_specifications {
    resource_type = "instance"

    tags = local.asg_tags
  }

  user_data = filebase64("${path.module}/user-data.sh")
}

