# FIAP 12SOAT - Fase 3 - Aurora PostgreSQL Database

## Descrição

Repositório responsável pela criação e gerenciamento do banco de dados Aurora PostgreSQL Serverless v2 para o sistema de Oficina Mecânica. Consome a infraestrutura de VPC e subnets criada pelo repositório `fiap-12soat-projeto-fase-3-terraform`.

## Estrutura do Projeto

```
fiap-12soat-projeto-fase-3-banco/
├── terraform/
│   ├── aurora.tf          # Configuração do Aurora PostgreSQL Serverless v2
│   ├── main.tf            # Provider AWS
│   ├── backend.tf         # S3 Backend para state
│   ├── variables.tf       # Variáveis do Terraform
│   ├── outputs.tf         # Outputs (endpoints, nomes, IDs)
│   └── provider.tf        # Required providers
├── .github/
│   └── workflows/
│       ├── deploy.yaml         # Pipeline de deploy
│       ├── destroy.yaml        # Pipeline de destroy
│       └── pr-validation.yaml  # Validação de PRs
├── .gitignore
└── README.md
```

## Recursos Criados

### Aurora PostgreSQL Serverless v2
- **Cluster**: Aurora PostgreSQL 15.4
- **Modo**: Serverless v2 (escala automática)
- **Capacidade**: 0.5 - 1.0 ACUs (configurável)
- **Backup**: Retenção de 7 dias
- **Logs**: CloudWatch Logs habilitado

### Networking
- **Security Group**: Acesso PostgreSQL (5432) apenas de dentro da VPC
- **Subnet Group**: Usa as subnets públicas da infraestrutura existente
- **VPC**: Consome VPC criada pelo repositório de infraestrutura

## Pré-requisitos

1. Terraform >= 1.3
2. AWS CLI configurado
3. **Dependência**: Repositório `fiap-12soat-projeto-fase-3-terraform` já deve estar deployed
   - VPC criada
   - Subnets criadas
   - Terraform state disponível no S3

## Configuração Local

### 1. Inicializar Terraform

```powershell
cd terraform
terraform init
```

### 2. Configurar variáveis

Crie um arquivo `terraform.tfvars` (não commitado):

```hcl
aws_region              = "us-east-1"
environment             = "dev"
db_master_username      = "admin"
db_master_password      = "SuaSenhaSegura123!"
terraform_state_bucket  = "fiap-12soat-terraform-state"
terraform_state_key     = "infra/terraform.tfstate"
```

### 3. Deploy

```powershell
terraform plan
terraform apply
```

### 4. Obter endpoint do Aurora

```powershell
terraform output aurora_cluster_endpoint
```

## CI/CD - GitHub Actions

### Secrets necessários

Configure os seguintes secrets no repositório GitHub:

#### AWS
- `AWS_ACCESS_KEY_ID`: Access Key da AWS
- `AWS_SECRET_ACCESS_KEY`: Secret Key da AWS

#### Database
- `DB_MASTER_USERNAME`: Username master do Aurora (ex: `admin`)
- `DB_MASTER_PASSWORD`: Senha master do Aurora (mínimo 8 caracteres)

#### Terraform State
- `TERRAFORM_STATE_BUCKET`: Nome do bucket S3 com o state da infra (ex: `fiap-12soat-terraform-state`)
- `TERRAFORM_STATE_KEY`: Chave do state da infra no S3 (ex: `infra/terraform.tfstate`)

### Deploy Pipeline

1. Acesse **Actions** → **Deploy Aurora PostgreSQL**
2. Clique em **Run workflow**
3. Selecione o environment (`dev`, `staging`, `prod`)
4. Confirme

A pipeline irá:
- Validar configuração do Terraform
- Planejar mudanças
- Criar o cluster Aurora PostgreSQL
- Exibir endpoints de conexão

### Destroy Pipeline

1. Acesse **Actions** → **Destruir Aurora PostgreSQL**
2. Clique em **Run workflow**
3. Digite `destroy` no campo de confirmação
4. Confirme

⚠️ **ATENÇÃO**: Esta ação irá destruir **PERMANENTEMENTE** o banco de dados Aurora. Todos os dados serão perdidos (a menos que você tenha backups).

### PR Validation Pipeline

Valida automaticamente mudanças em Pull Requests:
- Executa `terraform validate`
- Executa `terraform plan`
- Garante que não há erros de configuração

## Conexão ao Banco de Dados

### Endpoint de Escrita (Read/Write)

```
aurora_cluster_endpoint = "fiap-oficina-aurora-cluster.cluster-xxxxx.us-east-1.rds.amazonaws.com"
```

### Endpoint de Leitura (Read-Only)

```
aurora_cluster_reader_endpoint = "fiap-oficina-aurora-cluster.cluster-ro-xxxxx.us-east-1.rds.amazonaws.com"
```

### String de Conexão

```
Host=<aurora_cluster_endpoint>
Port=5432
Database=oficina_mecanica
Username=<db_master_username>
Password=<db_master_password>
```

## Dependências entre Repositórios

```
fiap-12soat-projeto-fase-3-terraform (infraestrutura base)
    ↓ (consome VPC e subnets)
fiap-12soat-projeto-fase-3-banco (este repositório)
    ↓ (fornece endpoint do banco)
fiap-12soat-projeto-fase-3-lambda + fiap-12soat-projeto-fase-3-aplicacao
```

## Segurança

- ✅ Aurora dentro da VPC (não acessível publicamente)
- ✅ Security Group permite acesso apenas de dentro da VPC
- ✅ Credenciais gerenciadas via GitHub Secrets
- ✅ Backups automáticos com retenção de 7 dias
- ✅ CloudWatch Logs habilitado para auditoria
- ✅ Conexões criptografadas (SSL/TLS)

## Monitoramento

### CloudWatch Logs

Logs do PostgreSQL disponíveis em:
```
/aws/rds/cluster/fiap-oficina-aurora-cluster/postgresql
```

### Métricas

- **DatabaseConnections**: Número de conexões ativas
- **CPUUtilization**: Utilização de CPU
- **ServerlessDatabaseCapacity**: Capacidade atual em ACUs
- **ReadLatency / WriteLatency**: Latência de leitura/escrita

## Custos

Aurora Serverless v2 cobra por:
- **ACU-Hour**: Capacidade computacional (0.5-1.0 ACU configurado)
- **Storage**: Armazenamento de dados (por GB/mês)
- **I/O**: Operações de entrada/saída

**Estimativa para desenvolvimento (0.5 ACU, 10GB)**:
- ~$50-70/mês (uso intermitente)

⚠️ Lembre-se de destruir o ambiente quando não estiver usando para evitar custos!

## Troubleshooting

### Erro: "VPC not found"

Certifique-se de que o repositório de infraestrutura foi deployed primeiro:
```powershell
cd c:\Repositorios\fiap-12soat-projeto-fase-3-terraform\infra
terraform apply
```

### Erro: "Subnet group requires at least 2 subnets"

O Aurora requer pelo menos 2 subnets em diferentes AZs. Verifique se a infraestrutura criou múltiplas subnets.

### Erro: "Invalid remote state"

Verifique se as variáveis `terraform_state_bucket` e `terraform_state_key` estão corretas e apontam para o state da infraestrutura.

## Próximos Passos

- [ ] Configurar Lambda para acessar Aurora via VPC
- [ ] Configurar aplicação EKS para acessar Aurora
- [ ] Implementar migrations do banco de dados
- [ ] Configurar read replicas para alta disponibilidade
- [ ] Implementar secrets rotation via AWS Secrets Manager
- [ ] Configurar alertas de monitoramento

## Licença

Projeto acadêmico - FIAP 12SOAT

## Contato

Equipe FIAP 12SOAT - Fase 3