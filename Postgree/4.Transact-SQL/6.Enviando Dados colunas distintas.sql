-- ==============================================================================
-- PROJETO DE ENGENHARIA DE DADOS: PIPELINE ANAC NO POSTGRESQL
-- SCRIPT SQL: CRIAÇÃO E GESTÃO DA TABELA COM COLUNAS DISTINTAS (MAPEAMENTO / DE-PARA)
-- Arquivo: 6.Enviando Dados colunas distintas.sql
-- ==============================================================================
--
-- 📌 CONCEITO: MAPEAMENTO DE COLUNAS (DE-PARA)
-- Na Engenharia de Dados real, é muito comum que os nomes das colunas no arquivo
-- de origem (JSON / Pandas DataFrame) sejam diferentes dos nomes no banco de destino.
--
-- 📋 TABELA DE MAPEAMENTO (DE-PARA):
-- ┌──────────────────────────────────┬─────────────────────────────┬───────────────┐
-- │ Origem no Python (DataFrame)     │ Destino no PostgreSQL       │ Tipo de Dado  │
-- ├──────────────────────────────────┼─────────────────────────────┼───────────────┤
-- │ Numero_da_Ocorrencia             │ ID                          │ INT           │
-- │ Classificacao_da_Ocorrencia      │ Classificacao_da_Ocorrencia │ VARCHAR(50)   │
-- │ Data_da_Ocorrencia               │ Dt_da_Ocorrencia            │ DATE          │
-- │ Municipio                        │ Municipio                   │ VARCHAR(50)   │
-- │ UF                               │ UF                          │ VARCHAR(30)   │
-- │ Regiao                           │ Regiao                      │ VARCHAR(30)   │
-- │ Nome_do_Fabricante               │ Fabri                       │ VARCHAR(100)  │
-- │ Modelo                           │ Modelo                      │ VARCHAR(50)   │
-- └──────────────────────────────────┴─────────────────────────────┴───────────────┘


-- ==============================================================================
-- 1. DDL: CRIAÇÃO DA TABELA 'anac_mapeamento'
-- ==============================================================================
-- CREATE TABLE: Comando DDL (Data Definition Language) que cria uma nova tabela.
-- IF NOT EXISTS: Só cria a tabela se ela ainda não existir, evitando erros ao reexecutar.

CREATE TABLE IF NOT EXISTS anac_mapeamento (

    -- ID: Código identificador da ocorrência (recebe 'Numero_da_Ocorrencia' do Python).
    -- INT: Números inteiros (ex.: 33947, 29123).
    ID INT,

    -- Classificacao_da_Ocorrencia: Nível de gravidade (ex.: 'Incidente', 'Acidente', 'Incidente Grave').
    -- VARCHAR(50): Texto variável com limite de até 50 caracteres.
    Classificacao_da_Ocorrencia VARCHAR(50),

    -- Dt_da_Ocorrencia: Data em que o fato aconteceu (recebe 'Data_da_Ocorrencia' do Python).
    -- DATE: Tipo específico para datas no formato internacional AAAA-MM-DD.
    Dt_da_Ocorrencia DATE,

    -- Municipio: Cidade onde ocorreu o fato (ex.: 'PALMAS', 'SAO PAULO').
    -- VARCHAR(50): Texto com limite de até 50 caracteres.
    Municipio VARCHAR(50),

    -- UF: Sigla da Unidade Federativa / Estado (ex.: 'SP', 'RJ', 'TO').
    -- VARCHAR(30): Texto com limite de até 30 caracteres.
    UF VARCHAR(30),

    -- Regiao: Região geográfica brasileira (ex.: 'Sudeste', 'Sul', 'Norte', 'Centro-Oeste', 'Nordeste').
    -- VARCHAR(30): Texto com limite de até 30 caracteres.
    Regiao VARCHAR(30),

    -- Fabri: Nome do fabricante da aeronave (recebe 'Nome_do_Fabricante' do Python).
    -- VARCHAR(100): Texto com limite de até 100 caracteres (ex.: 'EMBRAER', 'BOEING').
    Fabri VARCHAR(100),

    -- Modelo: Modelo da aeronave (recebe 'Modelo' do Python, ex.: 'EMB-201', 'PC-12/47E').
    -- VARCHAR(50): Texto com limite de até 50 caracteres.
    Modelo VARCHAR(50)
);


-- ==============================================================================
-- 2. DDL: ALTERAÇÃO DA TABELA (CASO PRECISE ADICIONAR COLUNAS POSTERIORMENTE)
-- ==============================================================================
-- Se a tabela já tiver sido criada antes sem a coluna 'Modelo', este comando
-- adiciona a nova coluna sem apagar os dados existentes:
ALTER TABLE anac_mapeamento 
ADD COLUMN IF NOT EXISTS Modelo VARCHAR(50);

-- Exemplo: Se você quisesse manter o nome original da coluna em vez de 'ID':
-- ALTER TABLE anac_mapeamento 
-- ADD COLUMN IF NOT EXISTS "Numero_da_Ocorrencia" INT;


-- ==============================================================================
-- 3. INSPEÇÃO DE METADADOS: CONFERIR ESTRUTURA E NOMES DAS COLUNAS NO BANCO
-- ==============================================================================
-- Consulta o dicionário interno do PostgreSQL (information_schema) para listar
-- todas as colunas existentes na tabela 'anac_mapeamento' e seus tipos de dados:
SELECT 
    column_name AS nome_coluna,
    data_type AS tipo_dado,
    character_maximum_length AS tamanho_maximo
FROM information_schema.columns
WHERE table_name = 'anac_mapeamento'
ORDER BY ordinal_position;


-- ==============================================================================
-- 4. DML: LIMPEZA DA BASE ANTES DA CARGA (DELETE / TRUNCATE)
-- ==============================================================================
-- Para garantir que o número de linhas no banco fique idêntico ao do arquivo
-- e evitar dados duplicados a cada execução do pipeline:

-- Opção Recomendada (TRUNCATE):
-- Esvazia a tabela instantaneamente e reinicia o armazenamento.
TRUNCATE TABLE anac_mapeamento;

-- Opção Alternativa (DELETE):
-- Apaga linha por linha (mais lento para grandes volumes de dados).
-- DELETE FROM anac_mapeamento;


-- ==============================================================================
-- 5. DQL: CONSULTAS DE VALIDAÇÃO DOS DADOS APÓS A CARGA
-- ==============================================================================

-- 1. Conferir o total de registros inseridos (deve bater exatamente com o DataFrame):
SELECT COUNT(*) AS total_registros FROM anac_mapeamento;

-- 2. Visualizar as 10 primeiras linhas carregadas na tabela:
SELECT * FROM anac_mapeamento LIMIT 10;

-- 3. Consulta analítica de exemplo: Total de ocorrências por classificação
SELECT 
    Classificacao_da_Ocorrencia,
    COUNT(*) AS total
FROM anac_mapeamento
GROUP BY Classificacao_da_Ocorrencia
ORDER BY total DESC;

-- 4. Consulta analítica de exemplo: Top 5 fabricantes com mais ocorrências
SELECT 
    Fabri,
    COUNT(*) AS total
FROM anac_mapeamento
WHERE Fabri IS NOT NULL
GROUP BY Fabri
ORDER BY total DESC
LIMIT 5;
