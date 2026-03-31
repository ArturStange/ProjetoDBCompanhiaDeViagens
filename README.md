# Sistema de Base de Dados para Agência de Turismo ✈️🗄️

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-F29111?style=for-the-badge&logo=postgresql&logoColor=white)
![Data Engineering](https://img.shields.io/badge/Data_Engineering-007396?style=for-the-badge)

## 📌 Visão Geral
Este projeto consiste no desenvolvimento completo de um Sistema de Base de Dados Relacional robusto para uma agência de turismo ("Viagens & Aventuras Ltda"). O projeto abrange desde a modelação conceptual e física (em 3ª Forma Normal) até à implementação de lógicas de negócio complexas, controlo de segurança, testes de concorrência e otimização de performance com grandes volumes de dados (mais de 1 milhão de registos).

## ✨ Principais Funcionalidades e Tópicos Abordados
* **Modelação Relacional (DDL):** Estrutura normalizada (3FN) abrangendo clientes, funcionários, destinos, hotéis, pacotes turísticos, reservas, pagamentos e avaliações.
* **Lógica de Negócio (Functions):** Criação de rotinas complexas para validação de reservas e cálculo automático de comissões de vendedores.
* **Gatilhos e Auditoria (Triggers):** Implementação de um sistema de auditoria que regista automaticamente qualquer operação de `INSERT`, `UPDATE` ou `DELETE` em tabelas críticas (compliance de dados).
* **Vistas (Views):** Construção de relatórios consolidados e dashboards executivos para simplificar consultas ao sistema.
* **Otimização e Tuning:** Uso prático de índices (B-Tree, compostos) e análise de execução de queries com `EXPLAIN ANALYZE` para melhoria de performance.
* **Controlo de Concorrência (TCL):** Simulação e resolução de cenários de concorrência, utilização de locks (`FOR UPDATE`) e diferentes níveis de isolamento em transações financeiras.
* **Segurança e Controlo de Acesso (DCL):** Criação de diferentes papéis (*Roles*) como `admin_agencia`, `operador_vendas` e `auditor_financeiro`, com permissões granulares (`GRANT`/`REVOKE`).
* **Stress Test (Carga Massiva):** Script otimizado (PL/pgSQL) para popular tabelas com mais de 8 milhões de registos totais, simulando um ambiente de produção real para testes de stress.

## 📂 Estrutura do Projeto

A execução dos scripts deve seguir a ordem abaixo para garantir a integridade referencial:

1. `etapa1_modelagem_criacao.sql`: Criação da base de dados, tabelas e chaves (PKs/FKs).
2. `etapa2_populacao_consultas.sql`: Inserção de dados iniciais (DML) e queries analíticas.
3. `etapa3_1_views.sql`: Criação de vistas (Views) para relatórios.
4. `etapa3_2_triggers.sql`: Configuração de gatilhos de auditoria e validação.
5. `etapa3_3_functions.sql`: Funções (Stored Procedures) para automação de processos.
6. `etapa3_4_indices_otimizacao.sql`: Criação de índices e testes de velocidade.
7. `etapa3_5_transacoes_concorrencia.sql`: Testes de atomicidade, commits e rollbacks.
8. `etapa3_6_seguranca_controle_acesso.sql`: Criação de utilizadores e gestão de permissões.
9. `etapa3_7_performance_tuning.sql`: Refatoração de queries lentas.
10. `popular_tabelas.sql`: Script de inserção massiva de dados (Geração de carga para testes de volume).

## 🛠️ Tecnologias Utilizadas
* **Sistema de Gestão de Base de Dados (SGBD):** PostgreSQL
* **Linguagem:** SQL (DDL, DML, DQL, DCL, TCL) e PL/pgSQL
* **Ferramenta de Gestão:** pgAdmin 4 (ou DBeaver / DataGrip)

## 🚀 Como Executar o Projeto

### Pré-requisitos
* PostgreSQL instalado e a correr na máquina local ou num servidor.
* Um cliente SQL (pgAdmin, DBeaver, psql).

### Passos de Instalação
1. Clona este repositório para a tua máquina local:
   ```bash
   git clone [https://github.com/ArturStange/ProjetoDBCompanhiaDeViagens.git](https://github.com/ArturStange/ProjetoDBCompanhiaDeViagens.git)
