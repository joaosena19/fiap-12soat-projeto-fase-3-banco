# Identificação

Aluno: João Pedro Sena Dainese  
Registro FIAP: RM365182  

Turma 12SOAT - Software Architecture  
Grupo individual  
Grupo 15  

Discord: joaodainese  
Email: joaosenadainese@gmail.com  

## Sobre este Repositório

Este repositório contém apenas parte do projeto completo da Fase 3. Para visualizar a documentação completa, diagramas de arquitetura, e todos os componentes do projeto, acesse: [Documentação Completa - Fase 3](https://github.com/joaosena19/fiap-12soat-projeto-fase-3-documentacao)

## Descrição

Banco de dados PostgreSQL hospedado no Amazon RDS para armazenar os dados da aplicação Oficina Mecânica. Instância única configurada com backup e integrada à VPC da infraestrutura principal.

## Tecnologias Utilizadas

- **PostgreSQL** - Banco relacional
- **AWS RDS** - Banco gerenciado
- **Terraform** - Infraestrutura como código
- **AWS VPC** - Isolamento de rede

## Passos para Execução

### 1. Configurar Variáveis

Criar `terraform.tfvars`:
```hcl
db_master_username = "postgres"
db_master_password = "SuaSenhaSegura123!"
terraform_state_bucket = "seu-bucket-tfstate"
```

### 2. Deploy

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 3. Obter Endpoint

```bash
terraform output postgres_instance_endpoint
```

## Diagramas de Arquitetura

Para visualizar os diagramas do modelo ER do banco de dados, consulte a documentação completa: [Modelo ER do Banco de Dados](https://github.com/joaosena19/fiap-12soat-projeto-fase-3-documentacao/blob/main/5.%20Banco%20de%20dados%20e%20modelo%20ER/1_banco_de_dados_modelo_er.md)
