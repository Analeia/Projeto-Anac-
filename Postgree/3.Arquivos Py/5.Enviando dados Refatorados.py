"""
==============================================================================
PROJETO ENGENHARIA DE DADOS - PIPELINE ETL (ANAC ➔ POSTGRESQL)
Versão Refatorada (Script .py)
==============================================================================
Fluxo do Pipeline:
1. Extração: Lê o arquivo JSON com dados da ANAC.
2. Transformação: Filtra as 7 colunas desejadas e remove acentos dos nomes.
3. Carga: Conecta ao PostgreSQL, limpa a base (TRUNCATE) e insere as linhas.
4. Validação: Confere se o total gravado no banco bate com o arquivo.
==============================================================================
"""

import pandas as pd
import psycopg2

# ==============================================================================
# 1. EXTRAÇÃO DOS DADOS (LEITURA DO JSON)
# ==============================================================================
print(" Iniciando o pipeline...")

# Caminho do arquivo JSON no computador -criacao de uma raw string (r"") para evitar problemas com barras invertidas
#  e variáveis de ambiente
caminho_do_arquivo = r"/Users/analeia/Desktop/Engenharia de Dados/V_OCORRENCIA_AMPLA.json"

# Lê o JSON e carrega em memória como um DataFrame (tabela do Pandas)
# encoding='utf-8-sig' garante que acentos da língua portuguesa sejam lidos sem erros
db = pd.read_json(caminho_do_arquivo, encoding="utf-8-sig")
print(f" Arquivo carregado com sucesso! Total de linhas: {len(db)}")


# ==============================================================================
# 2. TRANSFORMAÇÃO E LIMPEZA DOS DADOS
# ==============================================================================
# Lista apenas as 7 colunas que queremos salvar no banco de dados
colunas = [
    "Numero_da_Ocorrencia",
    "Classificacao_da_Ocorrência",
    "Data_da_Ocorrencia",
    "Municipio",
    "UF",
    "Regiao",
    "Nome_do_Fabricante",
]
db = db[colunas]

# Remove o acento da coluna (boa prática: nomes de colunas sem acentos no banco)
db = db.rename(columns={"Classificacao_da_Ocorrência": "Classificacao_da_Ocorrencia"})
print(" Colunas filtradas e padronizadas sem acentos.")


# ==============================================================================
# 3. CARGA NO POSTGRESQL (LOAD)
# ==============================================================================
# Parâmetros de acesso ao banco de dados
dbname = "python"
user = "analeia"
password = "12345"
host = "localhost"
port = "5432"

# Abre a conexão com o PostgreSQL
print("🔌 Conectando ao PostgreSQL...")
conn = psycopg2.connect(
    dbname=dbname,
    user=user,
    password=password,
    host=host,
    port=port,
)

# Cria o cursor (objeto que executa os comandos SQL no banco)
cur = conn.cursor()

# Cria a tabela Anac se ela ainda não existir
cur.execute("""
CREATE TABLE IF NOT EXISTS Anac (
    Numero_da_Ocorrencia INT,
    Classificacao_da_Ocorrencia VARCHAR(50),
    Data_da_Ocorrencia DATE,
    Municipio VARCHAR(50),
    UF VARCHAR(30),
    Regiao VARCHAR(30),
    Nome_do_Fabricante VARCHAR(100)
);
""")

# Limpa todos os dados anteriores para não duplicar registros a cada execução
print("🧹 Limpando dados antigos da tabela (TRUNCATE)...")
cur.execute("TRUNCATE TABLE Anac;")

# Percorre cada linha do DataFrame e insere na tabela do banco de dados
print(f"📥 Inserindo {len(db)} linhas no banco...")
for indice, coluna in db.iterrows():
    cur.execute("""
    INSERT INTO Anac (
        Numero_da_Ocorrencia,
        Classificacao_da_Ocorrencia,
        Data_da_Ocorrencia,
        Municipio,
        UF,
        Regiao,
        Nome_do_Fabricante
    ) VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (
        coluna["Numero_da_Ocorrencia"],
        coluna["Classificacao_da_Ocorrencia"],
        coluna["Data_da_Ocorrencia"],
        coluna["Municipio"],
        coluna["UF"],
        coluna["Regiao"],
        coluna["Nome_do_Fabricante"],
    ))

# Grava definitivamente todas as alterações no banco de dados
conn.commit()


# ==============================================================================
# 4. VALIDAÇÃO DO NÚMERO DE LINHAS E ENCERRAMENTO
# ==============================================================================
# Consulta o total de registros gravados para conferir com o DataFrame original
cur.execute("SELECT COUNT(*) FROM Anac;")
total_no_banco = cur.fetchone()[0]

print("-" * 50)
print(f"📊 Linhas no arquivo original: {len(db)}")
print(f"📊 Linhas no banco de dados:   {total_no_banco}")
print("-" * 50)

if len(db) == total_no_banco:
    print("🎉 Sucesso! A quantidade no banco bate 100% com o arquivo.")
else:
    print("⚠️ Atenção: A quantidade de linhas divergiu.")

# Fecha o cursor e a conexão para liberar memória e conexões abertas no servidor
cur.close()
conn.close()
print("🔒 Conexão encerrada com segurança.")
