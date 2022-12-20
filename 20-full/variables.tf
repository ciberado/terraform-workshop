variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "prefix" {
  description = "Prefix used to create the name of the resources"
  type = string
  default = "demo"
}

variable "owner" {
  description = "Owner of the infrastructure"
  type = string
  default = "Unknown"
}


variable "vpc_addr_prefix" {
  description = "16 first bits of the VPC prefix, like 10.0"
  type = string
  default = "Unknown"
}
