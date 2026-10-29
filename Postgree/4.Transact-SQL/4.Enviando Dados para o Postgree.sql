-- ==============================================================================
-- SCRIPT DDL: CRIAÇÃO DA TABELA 'Anac' NO BANCO POSTGRESQL
-- ==============================================================================
-- Este script define a estrutura da tabela que receberá os dados tratados
-- vindos do arquivo JSON de ocorrências aeronáuticas da ANAC.

-- CREATE TABLE: Comando DDL (Data Definition Language) que cria uma nova tabela.
-- IF NOT EXISTS: Cláusula de segurança que cria a tabela somente se ela ainda não existir.
--                Caso a tabela já exista, o PostgreSQL não gera erro e mantém a existente.
-- Anac: Nome dado à tabela no banco de dados.
CREATE Table IF NOT EXISTS Anac (

    -- Numero_da_Ocorrencia: Código numérico único que identifica cada ocorrência.
    -- INT: Tipo inteiro (números inteiros de 4 bytes, ex.: 33947, 29123).
    Numero_da_Ocorrencia INT,

    -- Classificacao_da_Ocorrencia: Gravidade do evento (ex.: 'Incidente', 'Acidente', 'Incidente Grave').
    -- VARCHAR(50): Texto de tamanho variável que suporta até 50 caracteres alfanuméricos.
    Classificacao_da_Ocorrencia VARCHAR(50),

    -- Data_da_Ocorrencia: Data em que o evento ocorreu.
    -- DATE: Tipo de dado específico para data no formato padrão internacional AAAA-MM-DD.
    Data_da_Ocorrencia DATE,

    -- Municipio: Nome da cidade/município onde ocorreu o fato (ex.: 'PALMAS', 'SAO PAULO').
    -- VARCHAR(50): Texto com limite de até 50 caracteres.
    Municipio VARCHAR(50),

    -- UF: Sigla da Unidade Federativa / Estado (ex.: 'SP', 'RJ', 'TO').
    -- VARCHAR(30): Texto com limite de até 30 caracteres.
    UF VARCHAR(30),

    -- Regiao: Região geográfica brasileira (ex.: 'Sudeste', 'Sul', 'Norte', 'Centro-Oeste', 'Nordeste').
    -- VARCHAR(30): Texto com limite de até 30 caracteres.
    Regiao VARCHAR(30),

    -- Nome_do_Fabricante: Nome do fabricante da aeronave (ex.: 'EMBRAER', 'BOEING', 'CESSNA AIRCRAFT').
    -- VARCHAR(100): Texto com limite de até 100 caracteres para suportar nomes mais longos.
    Nome_do_Fabricante VARCHAR(100)
);

-- ==============================================================================
-- COMANDOS SQL ADICIONAIS PARA O PROJETO:
-- ==============================================================================

-- Passo 7 do projeto: "Criar um Delete da tabela para não ter histórico,
-- mantendo em banco sempre os dados mais recentes"

-- Opção 1: DELETE FROM
-- Apaga todas as linhas da tabela Anac uma por uma.
-- DELETE FROM Anac;

-- Opção 2: TRUNCATE TABLE (Recomendado para Engenharia de Dados)
-- Limpa a tabela inteira instantaneamente, liberando espaço em disco de forma muito mais rápida.
-- TRUNCATE TABLE Anac;

-- Para consultar e validar os dados após a inserção:
-- SELECT * FROM Anac LIMIT 10;
