variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "prefix" {
  description = "Prefix used to create the name of the resources"
  type        = string
  default     = "demo"
}

variable "vpc_addr_prefix" {
  description = "16 first bits of the VPC prefix, like 10.0"
  type        = string
  default     = "10.0"
}

variable "app_instance_type" {
  description = "Instance type for the compute layer."
  type        = string
  default     = "t3.small"
}

variable "rds_instance_type" {
  description = "Instance type for the database layer."
  type        = string
  default     = "db.t3.small"
}

variable "environment" {
  description = "The environment of the project."
  type        = string
}

variable "tags" {
  type = map(any)
  default = {
    Owner = "Unknown" /* Owner of the infrastructure */
  }
}