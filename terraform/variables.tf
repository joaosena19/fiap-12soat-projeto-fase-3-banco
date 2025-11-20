variable "aws_region" {
  description = "Região da AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "project_identifier" {
  description = "Identificador único do projeto"
  type        = string
  default     = "fiap-12soat-fase3"
}

variable "db_cluster_identifier" {
  description = "Identificador do cluster Aurora PostgreSQL"
  type        = string
  default     = "fiap-oficina-aurora-cluster"
}

variable "db_name" {
  description = "Nome do banco de dados inicial"
  type        = string
  default     = "oficina_mecanica"
}

variable "db_master_username" {
  description = "Username do usuário master do banco de dados"
  type        = string
  sensitive   = true
}

variable "db_master_password" {
  description = "Senha do usuário master do banco de dados"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Porta do banco de dados PostgreSQL"
  type        = number
  default     = 5432
}

variable "backup_retention_period" {
  description = "Número de dias para reter backups automáticos"
  type        = number
  default     = 0
}

variable "preferred_backup_window" {
  description = "Janela de tempo preferida para backups (UTC)"
  type        = string
  default     = "03:00-04:00"
}

variable "preferred_maintenance_window" {
  description = "Janela de tempo preferida para manutenção (UTC)"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "skip_final_snapshot" {
  description = "Determina se um snapshot final deve ser criado antes da deleção"
  type        = bool
  default     = true
}

variable "aurora_engine_version" {
  description = "Versão do engine Aurora PostgreSQL"
  type        = string
  default     = "15.4"
}

variable "aurora_instance_class" {
  description = "Classe da instância Aurora (serverless v2 usa db.serverless)"
  type        = string
  default     = "db.serverless"
}

variable "aurora_serverless_min_capacity" {
  description = "Capacidade mínima em ACUs (Aurora Capacity Units) para Aurora Serverless v2"
  type        = number
  default     = 0.5
}

variable "aurora_serverless_max_capacity" {
  description = "Capacidade máxima em ACUs para Aurora Serverless v2"
  type        = number
  default     = 1.0
}

# Variáveis para consumir recursos da infraestrutura existente
variable "vpc_id" {
  description = "ID da VPC existente (será obtido via remote state ou data source)"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "IDs das subnets privadas existentes (será obtido via remote state ou data source)"
  type        = list(string)
  default     = []
}

variable "terraform_state_bucket" {
  description = "Nome do bucket S3 onde está o state da infraestrutura"
  type        = string
  default     = "fiap-12soat-fase3-joao-dainese"
}
