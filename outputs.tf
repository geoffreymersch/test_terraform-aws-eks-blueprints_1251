
# General output
output "region" {
  description = "AWS region where the cluster is provisioned"
  value       = module.vpc.region
}

# Kubernetes cluster
output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.vpc.cluster_name
}

output "vpc_private_subnets" {
  description = "VPC private subnets"
  value       = module.vpc.vpc_private_subnets
}

output "vpc_public_subnets" {
  description = "VPC public subnets"
  value       = module.vpc.vpc_public_subnets
}

# VPC output
output "cluster_vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

# Grafana output
output "grafana_admin_password" {
  description = "Grafana admin password"
  sensitive   = true
  value       = aws_secretsmanager_secret_version.grafana.secret_string
}

# Route53 output
output "aws_route53_zone" {
  description = "Route53 Hosted Zone ID"
  value       = aws_route53_zone.cluster_dns.id
}

output "aws_route53_zone_name_servers" {
  description = "Route53 Hosted Zone Nameservers"
  value       = aws_route53_zone.cluster_dns.name_servers
}