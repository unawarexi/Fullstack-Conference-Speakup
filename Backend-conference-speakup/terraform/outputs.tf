# ============================================================================
# SpeakUp — Terraform Outputs
# ============================================================================

# --------------------------------------------------------------------------
# VPC
# --------------------------------------------------------------------------
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

# --------------------------------------------------------------------------
# EKS
# --------------------------------------------------------------------------
output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "EKS cluster CA certificate"
  value       = module.eks.cluster_ca_certificate
  sensitive   = true
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}"
}

# --------------------------------------------------------------------------
# RDS PostgreSQL
# --------------------------------------------------------------------------
output "db_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.speakup.endpoint
}

output "db_connection_string" {
  description = "PostgreSQL connection string for Prisma"
  value       = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.speakup.endpoint}/${var.db_name}?schema=public"
  sensitive   = true
}

output "db_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.speakup.id
}

# --------------------------------------------------------------------------
# Redis
# --------------------------------------------------------------------------
output "redis_endpoint" {
  description = "ElastiCache Redis primary endpoint"
  value       = aws_elasticache_replication_group.speakup.primary_endpoint_address
}

output "redis_connection_string" {
  description = "Redis connection string"
  value       = "rediss://:${random_password.redis_auth.result}@${aws_elasticache_replication_group.speakup.primary_endpoint_address}:6379"
  sensitive   = true
}

# --------------------------------------------------------------------------
# Cloudflare
# --------------------------------------------------------------------------
output "cloudflare_zone_id" {
  description = "Cloudflare zone ID"
  value       = data.cloudflare_zone.main.id
}

output "api_url" {
  description = "API URL"
  value       = "https://api.${var.domain_name}"
}

output "ws_url" {
  description = "WebSocket URL"
  value       = "wss://ws.${var.domain_name}"
}

# --------------------------------------------------------------------------
# Security
# --------------------------------------------------------------------------
output "api_security_group_id" {
  description = "Security group ID for API pods"
  value       = aws_security_group.speakup_api.id
}

output "rds_security_group_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds.id
}

output "redis_security_group_id" {
  description = "Security group ID for Redis"
  value       = aws_security_group.redis.id
}