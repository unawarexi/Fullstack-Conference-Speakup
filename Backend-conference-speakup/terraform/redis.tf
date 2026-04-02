# ============================================================================
# SpeakUp — ElastiCache Redis
# For session caching, meeting state, and real-time communication
# ============================================================================

# --------------------------------------------------------------------------
# ElastiCache Subnet Group
# --------------------------------------------------------------------------
resource "aws_elasticache_subnet_group" "speakup" {
  name       = "${var.project_name}-redis-subnet"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Project = var.project_name
  }
}

# --------------------------------------------------------------------------
# Security Group for Redis
# --------------------------------------------------------------------------
resource "aws_security_group" "redis" {
  name_prefix = "${var.project_name}-redis-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for SpeakUp Redis"

  # Allow inbound from EKS worker nodes
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.speakup_api.id]
    description     = "Redis from API pods"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-redis-sg"
    Project = var.project_name
  }
}

# --------------------------------------------------------------------------
# ElastiCache Redis Replication Group
# --------------------------------------------------------------------------
resource "aws_elasticache_replication_group" "speakup" {
  replication_group_id = "${var.project_name}-redis"
  description          = "SpeakUp Redis cluster for caching and real-time data"

  node_type            = var.redis_node_type
  num_cache_clusters   = var.redis_num_cache_nodes
  port                 = 6379

  # Engine
  engine               = "redis"
  engine_version       = "7.1"
  parameter_group_name = aws_elasticache_parameter_group.speakup.name

  # Network
  subnet_group_name    = aws_elasticache_subnet_group.speakup.name
  security_group_ids   = [aws_security_group.redis.id]

  # Security
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = random_password.redis_auth.result

  # Availability
  automatic_failover_enabled = var.environment == "production"
  multi_az_enabled           = var.environment == "production"

  # Maintenance
  maintenance_window       = "sun:05:00-sun:06:00"
  snapshot_retention_limit  = var.environment == "production" ? 7 : 1
  snapshot_window           = "04:00-05:00"

  # Auto minor version upgrade
  auto_minor_version_upgrade = true

  tags = {
    Name        = "${var.project_name}-redis"
    Project     = var.project_name
    Environment = var.environment
  }
}

# --------------------------------------------------------------------------
# Redis Parameter Group (optimized for real-time meeting communication)
# --------------------------------------------------------------------------
resource "aws_elasticache_parameter_group" "speakup" {
  family = "redis7"
  name   = "${var.project_name}-redis-params"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  parameter {
    name  = "notify-keyspace-events"
    value = "Ex"  # Enable expired key notifications
  }

  tags = {
    Project = var.project_name
  }
}

# --------------------------------------------------------------------------
# Redis Auth Token
# --------------------------------------------------------------------------
resource "random_password" "redis_auth" {
  length  = 32
  special = false
}