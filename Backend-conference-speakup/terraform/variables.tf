
# ============================================================================
# SpeakUp — Terraform Variables
# ============================================================================

# --------------------------------------------------------------------------
# General
# --------------------------------------------------------------------------
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "speakup"
}

# --------------------------------------------------------------------------
# AWS
# --------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for the VPC"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# --------------------------------------------------------------------------
# EKS
# --------------------------------------------------------------------------
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "speakup-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.29"
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS worker nodes"
  type        = list(string)
  default     = ["t3.medium", "t3.large"]
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 10
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 3
}

# --------------------------------------------------------------------------
# RDS PostgreSQL
# --------------------------------------------------------------------------
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 50
}

variable "db_max_allocated_storage" {
  description = "Maximum auto-scaling storage in GB"
  type        = number
  default     = 200
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "speakup"
}

variable "db_username" {
  description = "Master database username"
  type        = string
  default     = "speakup_admin"
  sensitive   = true
}

variable "db_password" {
  description = "Master database password"
  type        = string
  sensitive   = true
}

# --------------------------------------------------------------------------
# ElastiCache Redis
# --------------------------------------------------------------------------
variable "redis_node_type" {
  description = "ElastiCache Redis node type"
  type        = string
  default     = "cache.t3.medium"
}

variable "redis_num_cache_nodes" {
  description = "Number of Redis cache nodes"
  type        = number
  default     = 2
}

# --------------------------------------------------------------------------
# Cloudflare
# --------------------------------------------------------------------------
variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for the domain"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name"
  type        = string
  default     = "speakup.app"
}
