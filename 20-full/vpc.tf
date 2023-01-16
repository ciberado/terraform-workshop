locals {
  name              = "${var.prefix}_VPC"
  addr_range_prefix = var.vpc_addr_prefix

  vpc_tags = merge({
    Layer : "network fabric"
  }, var.tags)
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = "${local.addr_range_prefix}.0.0/16"

  azs = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["${local.addr_range_prefix}.1.0/24",
    "${local.addr_range_prefix}.2.0/24",
  "${local.addr_range_prefix}.3.0/24"]
  public_subnets = ["${local.addr_range_prefix}.101.0/24",
    "${local.addr_range_prefix}.102.0/24",
  "${local.addr_range_prefix}.103.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_vpn_gateway = false

  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  tags = local.vpc_tags
}