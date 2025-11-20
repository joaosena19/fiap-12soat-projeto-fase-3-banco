# Data source para obter informações da VPC e subnets do terraform da infraestrutura
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "infra/terraform.tfstate"
    region = var.aws_region
  }
}

# Security Group para o RDS PostgreSQL
resource "aws_security_group" "aurora_sg" {
  name        = "${var.db_cluster_identifier}-sg"
  description = "Security group para RDS PostgreSQL Instance"
  vpc_id      = data.terraform_remote_state.infra.outputs.vpc_principal_id

  ingress {
    description = "Acesso PostgreSQL de dentro da VPC"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.infra.outputs.vpc_principal_cidr]
  }

  egress {
    description = "Permitir todo trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.db_cluster_identifier}-sg"
  }
}

# DB Subnet Group usando as subnets públicas da infraestrutura
# Nota: Em produção, idealmente usar subnets privadas
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "${var.db_cluster_identifier}-subnet-group"
  subnet_ids = data.terraform_remote_state.infra.outputs.subnet_publica_ids

  tags = {
    Name = "${var.db_cluster_identifier}-subnet-group"
  }
}

resource "aws_db_instance" "postgres_instance" {
  identifier     = var.db_cluster_identifier
  engine         = "postgres"
  engine_version = var.postgres_engine_version
  instance_class = var.postgres_instance_class
  
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  
  db_name  = var.db_name
  username = var.db_master_username
  password = var.db_master_password
  port     = var.db_port
  
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids = [aws_security_group.aurora_sg.id]

  backup_retention_period = var.backup_retention_period
  backup_window          = var.preferred_backup_window
  maintenance_window     = var.preferred_maintenance_window
  
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.db_cluster_identifier}-final-snapshot"

  publicly_accessible = false
  
  # Enable automated backups
  copy_tags_to_snapshot = true
  
  # Performance Insights
  performance_insights_enabled = false
  
  tags = {
    Name = var.db_cluster_identifier
  }
}
