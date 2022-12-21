module "lb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.prefix}_alb_sg"
  description = "ALB security group"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
}

resource "random_uuid" "bucket_uuid" {}

module "s3_bucket_for_logs" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.prefix}-app-alb-logs-${random_uuid.bucket_uuid.result}"
  acl    = "log-delivery-write"

  # Allow deletion of non-empty bucket
  force_destroy = true

  attach_elb_log_delivery_policy = true
  attach_lb_log_delivery_policy  = true
}


module "app_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "${var.prefix}ALB"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.lb_sg.security_group_id]


  access_logs = {
    bucket = module.s3_bucket_for_logs.s3_bucket_id
  }


  tags = {
    
  }
}