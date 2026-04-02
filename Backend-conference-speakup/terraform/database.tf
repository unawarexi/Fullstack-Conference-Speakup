
# ============================================================================
# UrbanRide Navii — RDS PostgreSQL (for Prisma)
# ============================================================================

# --------------------------------------------------------------------------
# DB Subnet Group
# --------------------------------------------------------------------------
resource "aws_db_subnet_group" "navii" {
  name       = "${var.project_name}-db-subnet"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name    = "${var.project_name}-db-subnet"
    Project = var.project_name
  }
}

# --------------------------------------------------------------------------
# Security Group for RDS
# --------------------------------------------------------------------------
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-rds-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for UrbanRide Navii PostgreSQL"

  # Allow inbound from EKS worker nodes
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.navii_api.id]
    description     = "PostgreSQL from API pods"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-rds-sg"
    Project = var.project_name
  }
}

# --------------------------------------------------------------------------
# RDS PostgreSQL Instance
# --------------------------------------------------------------------------
resource "aws_db_instance" "navii" {
  identifier = "${var.project_name}-postgres"

  engine         = "postgres"
  engine_version = "16.3"
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.navii.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # High availability
  multi_az = var.environment == "production"

  # Backup configuration
  backup_retention_period = var.environment == "production" ? 14 : 3
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  # Performance Insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  # Parameters
  parameter_group_name = aws_db_parameter_group.navii.name

  # Deletion protection
  deletion_protection = var.environment == "production"
  skip_final_snapshot = var.environment != "production"
  final_snapshot_identifier = var.environment == "production" ? "${var.project_name}-final-snapshot" : null

  tags = {
    Name        = "${var.project_name}-postgres"
    Project     = var.project_name
    Environment = var.environment
  }
}

# --------------------------------------------------------------------------
# DB Parameter Group (optimized for ride-hailing workload)
# --------------------------------------------------------------------------
resource "aws_db_parameter_group" "navii" {
  family = "postgres16"
  name   = "${var.project_name}-pg-params"

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"  # Log queries taking > 1s
  }

  parameter {
    name  = "max_connections"
    value = "200"
  }

  parameter {
    name  = "work_mem"
    value = "16384"  # 16MB
  }

  parameter {
    name  = "effective_cache_size"
    value = "1572864"  # ~1.5GB
  }

  tags = {
    Project = var.project_name
  }
}
