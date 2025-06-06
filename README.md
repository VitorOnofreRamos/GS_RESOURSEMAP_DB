# 🗄️ Documentação do Banco de Dados - ResourceMap

## 📋 Visão Geral

O banco de dados do **ResourceMap** foi projetado para suportar uma plataforma de coordenação de ajuda humanitária, permitindo o gerenciamento eficiente de organizações, usuários, necessidades, doações e correspondências entre recursos. A estrutura utiliza **Oracle Database** como SGBD principal.

## 🏗️ Arquitetura do Banco

### Características Principais
- **6 Tabelas Principais**: Organizadas para máxima eficiência e integridade
- **Sequences para IDs**: Geração automática de chaves primárias
- **Triggers de Auditoria**: Rastreamento completo de mudanças
- **Triggers de Timestamp**: Atualização automática de `updated_at`
- **Package PL/SQL**: Funcionalidades avançadas de CRUD e relatórios

## 📊 Estrutura das Tabelas

### 1. **GS_organizations** - Organizações Humanitárias
Armazena informações sobre ONGs, instituições de caridade e outras organizações.

```sql
CREATE TABLE GS_organizations (
    id                  NUMBER PRIMARY KEY,
    name                VARCHAR2(255) NOT NULL,
    description         CLOB,
    location            VARCHAR2(255) NOT NULL,
    contact_email       VARCHAR2(255),
    contact_phone       VARCHAR2(20),
    type                VARCHAR2(20), -- NGO, CHARITY, GOVERNMENT, RELIGIOUS, COMMUNITY
    created_at          TIMESTAMP NOT NULL,
    updated_at          TIMESTAMP
);
```

**Campos Principais:**
- **id**: Identificador único (gerado por sequence)
- **name**: Nome da organização
- **type**: Tipo da organização (NGO, CHARITY, GOVERNMENT, RELIGIOUS, COMMUNITY)
- **location**: Localização geográfica
- **contact_email/phone**: Informações de contato

### 2. **GS_users** - Usuários do Sistema
Gerencia todos os usuários da plataforma com diferentes perfis e permissões.

```sql
CREATE TABLE GS_users (
    id                  NUMBER PRIMARY KEY,
    email               VARCHAR2(255) UNIQUE NOT NULL,
    phone               VARCHAR2(20),
    name                VARCHAR2(255) NOT NULL,
    password_hash       VARCHAR2(255),
    role                VARCHAR2(20), -- DONOR, NGO_MEMBER, ADMIN
    is_active           CHAR(1) DEFAULT 'Y',
    last_login          TIMESTAMP,
    created_at          TIMESTAMP NOT NULL,
    updated_at          TIMESTAMP,
    organization_id     NUMBER,
    FOREIGN KEY (organization_id) REFERENCES GS_organizations(id)
);
```

**Campos Principais:**
- **id**: Identificador único do usuário
- **email**: Email único para login
- **role**: Tipo de usuário (DONOR, NGO_MEMBER, ADMIN)
- **is_active**: Status ativo/inativo
- **organization_id**: Referência à organização (FK)

### 3. **GS_needs** - Necessidades Humanitárias
Registra todas as necessidades identificadas pelas organizações.

```sql
CREATE TABLE GS_needs(
    id                  NUMBER PRIMARY KEY,
    title               VARCHAR2(255) NOT NULL,
    description         CLOB,
    location            VARCHAR2(255) NOT NULL,
    category            VARCHAR2(20), -- FOOD, WATER, CLOTHING, MEDICAL, SHELTER, EDUCATION, TRANSPORTATION, OTHER
    priority            VARCHAR2(10), -- LOW, MEDIUM, HIGH, CRITICAL
    status              VARCHAR2(20), -- ACTIVE, PARTIALLY_FULFILLED, FULFILLED, EXPIRED, CANCELLED
    quantity            NUMBER NOT NULL,
    unit                VARCHAR(50),
    deadline_date       TIMESTAMP,
    created_at          TIMESTAMP NOT NULL,
    updated_at          TIMESTAMP,
    creator_id          NUMBER NOT NULL,
    organization_id     NUMBER,
    FOREIGN KEY (creator_id) REFERENCES GS_users(id),
    FOREIGN KEY (organization_id) REFERENCES GS_organizations(id)
);
```

**Campos Principais:**
- **category**: Tipo de necessidade (FOOD, WATER, CLOTHING, MEDICAL, etc.)
- **priority**: Nível de urgência (LOW, MEDIUM, HIGH, CRITICAL)
- **status**: Estado atual (ACTIVE, PARTIALLY_FULFILLED, FULFILLED, etc.)
- **quantity/unit**: Quantidade e unidade de medida
- **creator_id**: Usuário que criou a necessidade (FK)

### 4. **GS_donations** - Doações Disponíveis
Armazena recursos disponibilizados por doadores.

```sql
CREATE TABLE GS_donations(
    id                  NUMBER PRIMARY KEY,
    title               VARCHAR2(255) NOT NULL,
    description         CLOB,
    location            VARCHAR(255) NOT NULL,
    category            VARCHAR2(20),
    status              VARCHAR2(20) DEFAULT 'AVAILABLE',
    quantity            NUMBER NOT NULL,
    unit                VARCHAR2(50),
    expiry_date        TIMESTAMP,
    created_at          TIMESTAMP,
    updated_at          TIMESTAMP,
    donor_id            NUMBER NOT NULL,
    FOREIGN KEY (donor_id) REFERENCES GS_users(id)
);
```

**Campos Principais:**
- **status**: Estado da doação (AVAILABLE, RESERVED, DONATED, EXPIRED)
- **expiry_date**: Data de validade (importante para alimentos/medicamentos)
- **donor_id**: Usuário doador (FK)

### 5. **GS_matches** - Correspondências Automatizadas
Liga necessidades com doações compatíveis através de algoritmos de matching.

```sql
CREATE TABLE GS_matches(
    id                  NUMBER PRIMARY KEY,
    need_id             NUMBER NOT NULL,
    donation_id         NUMBER NOT NULL,
    status              VARCHAR(20), -- PENDING, CONFIRMED, COMPLETED, REJECTED, CANCELLED
    matched_quantity    NUMBER,
    compatibility_score NUMBER(3), -- Decimal 0 - 100
    created_at          TIMESTAMP,
    updated_at          TIMESTAMP,
    confirmed_at        TIMESTAMP,
    notes               CLOB,
    FOREIGN KEY (need_id) REFERENCES GS_needs(id),
    FOREIGN KEY (donation_id) REFERENCES GS_donations(id)
);
```

**Campos Principais:**
- **compatibility_score**: Pontuação de compatibilidade (0-100)
- **matched_quantity**: Quantidade correspondida
- **status**: Estado do match (PENDING, CONFIRMED, COMPLETED, etc.)
- **confirmed_at**: Timestamp de confirmação

### 6. **GS_auditoria** - Auditoria Completa
Registra todas as operações realizadas nas tabelas principais.

```sql
CREATE TABLE GS_auditoria(
    id                  NUMBER PRIMARY KEY,
    table_name          VARCHAR2(50) NOT NULL,
    register_id         NUMBER NOT NULL,
    operation_type      VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    date_time           TIMESTAMP NOT NULL,
    db_user             VARCHAR2(50) NOT NULL,
    old_data            CLOB,
    new_data            CLOB
);
```

## 🔗 Relacionamentos Entre Tabelas

### Diagrama de Relacionamento

![Alt text](path/to/image.png)

### Relacionamentos Detalhados

#### **GS_organizations → GS_users** (1:N)
- Uma organização pode ter múltiplos usuários
- Usuários podem ser membros de uma organização (opcional)
- **FK**: `GS_users.organization_id → GS_organizations.id`

#### **GS_users → GS_needs** (1:N)
- Um usuário pode criar múltiplas necessidades
- Cada necessidade tem um criador obrigatório
- **FK**: `GS_needs.creator_id → GS_users.id`

#### **GS_organizations → GS_needs** (1:N)
- Uma organização pode ter múltiplas necessidades
- Necessidades podem ser associadas a organizações (opcional)
- **FK**: `GS_needs.organization_id → GS_organizations.id`

#### **GS_users → GS_donations** (1:N)
- Um usuário (doador) pode fazer múltiplas doações
- Cada doação tem um doador obrigatório
- **FK**: `GS_donations.donor_id → GS_users.id`

#### **GS_needs → GS_matches** (1:N)
- Uma necessidade pode ter múltiplos matches
- **FK**: `GS_matches.need_id → GS_needs.id`

#### **GS_donations → GS_matches** (1:N)
- Uma doação pode ter múltiplos matches
- **FK**: `GS_matches.donation_id → GS_donations.id`

#### **Todas as Tabelas → GS_auditoria**
- Todas as operações são registradas na auditoria
- Relacionamento conceitual via triggers

## ⚙️ Sequences e Automatização

### Sequences para Chaves Primárias
```sql
CREATE SEQUENCE seq_users START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_organizations START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_needs START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_donations START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_matches START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_auditoria START WITH 1 INCREMENT BY 1;
```

### Triggers de Timestamp Automático
Cada tabela principal possui um trigger que atualiza automaticamente o campo `updated_at`:

```sql
CREATE OR REPLACE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON GS_users
    FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
```

## 🔍 Sistema de Auditoria

### Triggers de Auditoria Completa
Cada tabela principal possui um trigger que registra:
- **INSERT**: Dados novos inseridos
- **UPDATE**: Dados antigos e novos
- **DELETE**: Dados removidos

### Exemplo de Trigger de Auditoria
```sql
CREATE OR REPLACE TRIGGER trg_auditoria_users
    AFTER INSERT OR UPDATE OR DELETE
    ON GS_users
    FOR EACH ROW
DECLARE
    v_dados_antigos CLOB;
    v_dados_novos CLOB;
    v_operacao VARCHAR2(10);
BEGIN
    -- Lógica para capturar operação e dados
    -- Inserir registro na tabela de auditoria
END;
```

### Benefícios da Auditoria
- **Rastreabilidade Completa**: Histórico de todas as mudanças
- **Segurança**: Detecção de alterações não autorizadas
- **Compliance**: Atendimento a requisitos regulatórios
- **Debug**: Análise de problemas e inconsistências

## 📦 Package PL/SQL - GS_MANAGEMENT_PKG

### Funcionalidades do Package

#### **1. Funções Analíticas**
```sql
-- Retorna total de necessidades ativas
FUNCTION get_total_active_needs RETURN NUMBER;

-- Calcula eficiência da organização
FUNCTION get_organization_efficiency(p_org_id NUMBER) RETURN NUMBER;

-- Determina nível de demanda por categoria
FUNCTION get_category_demand_level(p_category VARCHAR2) RETURN VARCHAR2;
```

#### **2. Procedimentos de Relatório**
```sql
-- Relatório de estatísticas por organização
PROCEDURE generate_organization_report(p_org_cursor OUT c_org_stats);

-- Relatório de doações por categoria
PROCEDURE generate_donation_summary(p_donation_cursor OUT c_donation_report);

-- Relatório de eficiência de matching
PROCEDURE generate_matching_efficiency_report;

-- Relatório de atividade mensal
PROCEDURE generate_monthly_activity_report(p_year NUMBER, p_month NUMBER);
```

#### **3. Operações CRUD Completas**
O package inclui procedimentos para todas as operações CRUD:
- **Organizations**: INSERT_ORGANIZATION, UPDATE_ORGANIZATION, DELETE_ORGANIZATION
- **Users**: INSERT_USER, UPDATE_USER, DELETE_USER
- **Needs**: INSERT_NEED, UPDATE_NEED, DELETE_NEED
- **Donations**: INSERT_DONATION, UPDATE_DONATION, DELETE_DONATION
- **Matches**: INSERT_MATCH, UPDATE_MATCH, DELETE_MATCH

### Validações Implementadas
- **Integridade Referencial**: Verificação de FKs válidas
- **Regras de Negócio**: Validação de tipos, status e quantidades
- **Consistência**: Verificação de dependências antes de exclusões
- **Tratamento de Erros**: Rollback automático em caso de falhas

## 🎯 Constraints e Validações

### Check Constraints Implementadas
```sql
-- Validação de roles de usuário
CONSTRAINT chk_users_role CHECK (role IN ('DONOR', 'NGO_MEMBER', 'ADMIN'))

-- Validação de status ativo
CONSTRAINT chk_users_active CHECK (is_active IN ('Y', 'N'))

-- Validação de prioridades
CONSTRAINT chk_needs_priority CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'))

-- Validação de quantidades positivas
CONSTRAINT chk_needs_quantity CHECK (quantity > 0)

-- Validação de score de compatibilidade
CONSTRAINT chk_compatibility_score CHECK (compatibility_score BETWEEN 0 AND 100)
```

### Unique Constraints
- **Email de usuário**: Garantia de unicidade
- **Match único**: Prevenção de duplicatas need_id + donation_id

## 📈 Casos de Uso do Sistema

### 1. **Registro de Necessidade**
```sql
-- Organização registra nova necessidade crítica
EXEC GS_MANAGEMENT_PKG.INSERT_NEED(
    p_title => 'Água potável para 100 famílias',
    p_location => 'Campinas, SP',
    p_category => 'WATER',
    p_priority => 'CRITICAL',
    p_quantity => 1000,
    p_unit => 'litros',
    p_creator_id => 5,
    p_organization_id => 2
);
```

### 2. **Registro de Doação**
```sql
-- Doador disponibiliza recursos
EXEC GS_MANAGEMENT_PKG.INSERT_DONATION(
    p_title => 'Garrafas de água mineral',
    p_location => 'São Paulo, SP',
    p_category => 'WATER',
    p_quantity => 500,
    p_unit => 'litros',
    p_donor_id => 3
);
```

### 3. **Criação de Match**
```sql
-- Sistema cria correspondência automática
EXEC GS_MANAGEMENT_PKG.INSERT_MATCH(
    p_need_id => 1,
    p_donation_id => 1,
    p_matched_quantity => 500,
    p_compatibility_score => 85
);
```

### 4. **Geração de Relatórios**
```sql
-- Relatório de eficiência mensal
EXEC GS_MANAGEMENT_PKG.generate_monthly_activity_report(2024, 6);

-- Relatório de eficiência de matching
EXEC GS_MANAGEMENT_PKG.generate_matching_efficiency_report;
```

## 🔧 Manutenção e Administração

### Consultas Úteis para Administração

#### **Estatísticas Gerais**
```sql
-- Resumo do sistema
SELECT 
    (SELECT COUNT(*) FROM GS_organizations) as total_orgs,
    (SELECT COUNT(*) FROM GS_users WHERE is_active = 'Y') as users_ativos,
    (SELECT COUNT(*) FROM GS_needs WHERE status = 'ACTIVE') as needs_ativas,
    (SELECT COUNT(*) FROM GS_donations WHERE status = 'AVAILABLE') as donations_disponiveis,
    (SELECT COUNT(*) FROM GS_matches WHERE status = 'PENDING') as matches_pendentes
FROM DUAL;
```

#### **Necessidades por Categoria**
```sql
-- Análise de demanda por categoria
SELECT 
    category,
    COUNT(*) as total,
    COUNT(CASE WHEN status = 'ACTIVE' THEN 1 END) as ativas,
    COUNT(CASE WHEN priority = 'CRITICAL' THEN 1 END) as criticas
FROM GS_needs 
GROUP BY category 
ORDER BY ativas DESC;
```

#### **Eficiência de Organizações**
```sql
-- Top organizações por matches confirmados
SELECT 
    o.name,
    COUNT(DISTINCT n.id) as necessidades_criadas,
    COUNT(DISTINCT m.id) as matches_realizados,
    ROUND(AVG(m.compatibility_score), 2) as score_medio
FROM GS_organizations o
LEFT JOIN GS_needs n ON o.id = n.organization_id
LEFT JOIN GS_matches m ON n.id = m.need_id AND m.status = 'CONFIRMED'
GROUP BY o.id, o.name
ORDER BY matches_realizados DESC;
```

## 🚀 Performance e Otimização

### Índices Recomendados
```sql
-- Índices para melhor performance
CREATE INDEX idx_users_email ON GS_users(email);
CREATE INDEX idx_users_org ON GS_users(organization_id);
CREATE INDEX idx_needs_category ON GS_needs(category);
CREATE INDEX idx_needs_status ON GS_needs(status);
CREATE INDEX idx_donations_category ON GS_donations(category);
CREATE INDEX idx_donations_status ON GS_donations(status);
CREATE INDEX idx_matches_need ON GS_matches(need_id);
CREATE INDEX idx_matches_donation ON GS_matches(donation_id);
CREATE INDEX idx_auditoria_table ON GS_auditoria(table_name, operation_type);
```

### Particionamento Sugerido
```sql
-- Particionamento da tabela de auditoria por data
ALTER TABLE GS_auditoria 
PARTITION BY RANGE (date_time) 
INTERVAL (NUMTOYMINTERVAL(1, 'MONTH'));
```

## 💡 Principais Vantagens da Estrutura

### **1. Escalabilidade**
- Sequences garantem IDs únicos em alta concorrência
- Estrutura normalizada permite crescimento eficiente
- Particionamento da auditoria para grandes volumes

### **2. Integridade**
- Foreign Keys garantem consistência referencial
- Check constraints validam regras de negócio
- Triggers mantêm auditoria completa

### **3. Flexibilidade**
- Campos opcionais permitem diferentes cenários
- Sistema de status contempla workflow completo
- Categorização extensível para novos tipos

### **4. Rastreabilidade**
- Auditoria completa de todas as operações
- Timestamps automáticos para controle temporal
- Histórico preservado para análises

### **5. Funcionalidade Avançada**
- Package PL/SQL com lógica centralizada
- Relatórios automatizados
- Cálculos de eficiência integrados

## 🔮 Extensões Futuras

### Melhorias Planejadas
1. **Geolocalização**: Adicionar coordenadas GPS para matching geográfico
2. **Workflow Avançado**: Estados mais granulares para necessidades
3. **Métricas de Impacto**: Campos para medir efetividade das doações
4. **Integração IoT**: Suporte a sensores para monitoramento em tempo real
5. **Machine Learning**: Tabelas para armazenar modelos de IA treinados

## 👥 Equipe de Desenvolvimento

- Beatriz Silva - RM552600
- Vitor Onofre Ramos - RM553241
- Pedro Henrique Soares Araujo - RM553801

---
