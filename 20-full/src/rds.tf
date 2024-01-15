locals {
  rds_tags = merge({
    Layer : "database"
  }, var.tags)
}

resource "random_password" "dbpassword" {
  length  = 10
  special = true
}

resource "aws_ssm_parameter" "rdssecret" {
  name        = "/${var.prefix}/${var.environment}/databases/password/master"
  description = "Initial password for the database"
  type        = "SecureString"
  value       = random_password.dbpassword.result
}

module "rds_mysql_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.prefix}_rds_mysql_sg"
  description = "Database security group for mysql"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "Mysql access from within VPC"

      source_security_group_id = module.app_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]
  tags = {
    Layer : "database"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${lower(var.prefix)}databasesubnetgroup"
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  tags = {
    Layer : "computing"
  }
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${lower(var.prefix)}db"

  engine               = "mysql"
  engine_version       = "5.7"
  family               = "mysql5.7"
  major_engine_version = "5.7"
  instance_class       = var.rds_instance_type

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name                = "petclinic"
  username               = "admin"
  password               = random_password.dbpassword.result

  port = 3306

  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [module.rds_mysql_sg.security_group_id]


  tags = {
    Layer : "database"
  }
}

resource "aws_ssm_parameter" "rdsendpoint" {
  name        = "/${var.prefix}/${var.environment}/databases/endpoint"
  description = "RDS endpoint"
  type        = "String"
  value       = module.db.db_instance_endpoint
}