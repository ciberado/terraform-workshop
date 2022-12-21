output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

output "vpc_flow_log_id" {
  description = "The ID of the Flow Log resource"
  value       = module.vpc.vpc_flow_log_id
}

output "app_alb_fqdn" {
  description = "The DNS name of the load balancer for the application"
  value = module.app_alb.lb_dns_name
}

output "ubuntu_ami_description" {
  value = data.aws_ami.ubuntu.description
}

output "ubuntu_ami_id" {
  value = data.aws_ami.ubuntu.id
}