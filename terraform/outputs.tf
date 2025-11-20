output "postgres_instance_id" {
  description = "ID da instância PostgreSQL RDS"
  value       = aws_db_instance.postgres_instance.id
}

output "postgres_instance_endpoint" {
  description = "Endpoint da instância PostgreSQL RDS"
  value       = aws_db_instance.postgres_instance.endpoint
}

output "postgres_instance_port" {
  description = "Porta da instância PostgreSQL RDS"
  value       = aws_db_instance.postgres_instance.port
}

output "postgres_database_name" {
  description = "Nome do banco de dados"
  value       = aws_db_instance.postgres_instance.db_name
}

output "postgres_master_username" {
  description = "Username master do banco de dados"
  value       = aws_db_instance.postgres_instance.username
  sensitive   = true
}

output "postgres_security_group_id" {
  description = "ID do Security Group do PostgreSQL"
  value       = aws_security_group.aurora_sg.id
}

output "postgres_subnet_group_name" {
  description = "Nome do DB Subnet Group"
  value       = aws_db_subnet_group.aurora_subnet_group.name
}
