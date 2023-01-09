locals {
  rds_tags = merge({
    Environment : terraform.workspace
    Creation : timestamp()
    Layer : "database"
  }, var.tags)
}

module "rds_postgres_sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name = "${var.prefix}_rds_postgres_sg"
  description = "Database security group for postgresql"
  vpc_id = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"

      source_security_group_id = module.app_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${lower(var.prefix)}databasesubnetgroup"
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]

  tags = local.rds_tags
}

module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "${lower(var.prefix)}db"

  engine               = "postgres"
  engine_version       = "14"
  family               = "postgres14"
  major_engine_version = "14"
  instance_class       = var.rds_instance_type

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "completePostgresql"
  username = "complete_postgresql"
  port     = 5432

  multi_az               = var.rds_multiaz
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [module.rds_postgres_sg.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "example-monitoring-role-name"
  monitoring_role_use_name_prefix       = true
  monitoring_role_description           = "Description for monitoring role"

  
  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = local.rds_tags

  db_option_group_tags = local.rds_tags
  
  db_parameter_group_tags = local.rds_tags
}

resource "aws_ssm_parameter" "rdssecret" {
  name = "/${var.tags.Environment}/databases/${var.prefix}/password/master"
  description = "Initial password for the database"
  type = "SecureString"
  value = module.db.db_instance_password
  overwrite = true
  tags = local.rds_tags
}