locals {
  asg_tags = merge({
    Layer : "computing"
  }, var.tags)
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] /* Ubuntu */

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

module "app_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name = "${var.prefix}_app_sg"
  description = "Application security group"
  vpc_id = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule = "http-8080-tcp"
      source_security_group_id = module.lb_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]
}


module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "${var.prefix}AppASG"

  min_size = 1
  max_size = 3
  desired_capacity = 1

  health_check_type = "EC2"
  vpc_zone_identifier = module.vpc.private_subnets

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay = 600
      checkpoint_percentages = [35, 70, 100]
      instance_warmup = 300
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  # Launch template
  launch_template_name = "${var.prefix}_launch_template"
  launch_template_description = "Launch template for ${var.prefix}"
  update_default_version = true

  image_id = data.aws_ami.ubuntu.id
  instance_type = var.app_instance_type
  ebs_optimized = true
  enable_monitoring = true

  create_launch_template = true

  create_iam_instance_profile = true
  iam_role_name = "${var.prefix}AppRole"
  iam_role_path = "/ec2/"
  iam_role_description = "IAM role for ${var.prefix}"
  iam_role_tags = {
    CustomIamRole = "Yes"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device = 0
      ebs = {
        delete_on_termination = true
        encrypted = true
        volume_size = 8
        volume_type = "gp3"
      }
    }
  ]

  capacity_reservation_specification = {
    capacity_reservation_preference = "open"
  }

  credit_specification = {
    cpu_credits = "standard"
  }

  instance_market_options = {
    market_type = "spot"
  }


  network_interfaces = [
    {
      delete_on_termination = true
      description = "eth0"
      device_index = 0
      security_groups = [module.app_sg.security_group_id]
    }
  ]

  tag_specifications = [
    {
      resource_type = "instance"
      tags = local.asg_tags
    },
    {
      resource_type = "volume"
      tags = local.asg_tags
    },
    {
      resource_type = "spot-instances-request"
      tags = local.asg_tags
    }
  ]

  user_data = filebase64("${path.module}/user-data.sh")

  tags = local.asg_tags
}