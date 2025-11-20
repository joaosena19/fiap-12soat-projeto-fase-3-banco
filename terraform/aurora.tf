# Data source para obter informações da VPC e subnets do terraform da infraestrutura
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = var.terraform_state_bucket
    key    = "infra/terraform.tfstate"
    region = var.aws_region
  }
}

# Security Group para o Aurora PostgreSQL
resource "aws_security_group" "aurora_sg" {
  name        = "${var.db_cluster_identifier}-sg"
  description = "Security group para Aurora PostgreSQL Cluster"
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

# Aurora PostgreSQL Serverless v2 Cluster
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier      = var.db_cluster_identifier
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  engine_version          = var.aurora_engine_version
  database_name           = var.db_name
  master_username         = var.db_master_username
  master_password         = var.db_master_password
  port                    = var.db_port
  
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.aurora_sg.id]

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window
  
  skip_final_snapshot          = var.skip_final_snapshot
  final_snapshot_identifier    = var.skip_final_snapshot ? null : "${var.db_cluster_identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  serverlessv2_scaling_configuration {
    min_capacity = var.aurora_serverless_min_capacity
    max_capacity = var.aurora_serverless_max_capacity
  }

  tags = {
    Name        = var.db_cluster_identifier
  }
}

# Aurora PostgreSQL Serverless v2 Instance
resource "aws_rds_cluster_instance" "aurora_instance" {
  identifier         = "${var.db_cluster_identifier}-instance-1"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = var.aurora_instance_class
  engine             = aws_rds_cluster.aurora_cluster.engine
  engine_version     = aws_rds_cluster.aurora_cluster.engine_version

  publicly_accessible = false

  tags = {
    Name        = "${var.db_cluster_identifier}-instance-1"
  }
}
