output "aurora_cluster_id" {
  description = "ID do cluster Aurora PostgreSQL"
  value       = aws_rds_cluster.aurora_cluster.id
}

output "aurora_cluster_endpoint" {
  description = "Endpoint de escrita do cluster Aurora"
  value       = aws_rds_cluster.aurora_cluster.endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "Endpoint de leitura do cluster Aurora"
  value       = aws_rds_cluster.aurora_cluster.reader_endpoint
}

output "aurora_cluster_port" {
  description = "Porta do cluster Aurora"
  value       = aws_rds_cluster.aurora_cluster.port
}

output "aurora_database_name" {
  description = "Nome do banco de dados"
  value       = aws_rds_cluster.aurora_cluster.database_name
}

output "aurora_master_username" {
  description = "Username master do banco de dados"
  value       = aws_rds_cluster.aurora_cluster.master_username
  sensitive   = true
}

output "aurora_security_group_id" {
  description = "ID do Security Group do Aurora"
  value       = aws_security_group.aurora_sg.id
}

output "aurora_subnet_group_name" {
  description = "Nome do DB Subnet Group"
  value       = aws_db_subnet_group.aurora_subnet_group.name
}
