-- NEXUS
-- DW
-- Dimensão: Cliente
-- ============================================================
/*
Origem:
    raw.customers

Destino:
    dw.dim_cliente

Grão:
    1 registro de cliente por linha

Responsabilidade:
    Representar o contexto de cliente no modelo analítico.

Observação:
    cliente_id identifica o registro de cliente.
    cliente_unico_id pode aparecer em múltiplos registros.
    O CEP é mantido como texto para preservar zeros à esquerda.

Atributos geográficos:
    uf     = sigla da unidade federativa
    estado = nome do estado
    regiao = região geográfica
*/

-- 01. RECRIAÇÃO DA TABELA
DROP TABLE IF EXISTS dw.dim_cliente;

CREATE TABLE dw.dim_cliente (
    cliente_id        VARCHAR(32)  NOT NULL,
    cliente_unico_id  VARCHAR(32)  NOT NULL,
    cep               VARCHAR(5)   NOT NULL,
    cidade            VARCHAR(100) NOT NULL,
    uf                CHAR(2)      NOT NULL,
    estado            VARCHAR(100),
    regiao            VARCHAR(20),

    PRIMARY KEY (cliente_id)
);

-- 02. TRANSFORMAÇÃO E CARGA
INSERT INTO dw.dim_cliente (
    cliente_id,
    cliente_unico_id,
    cep,
    cidade,
    uf,
    estado,
    regiao
)
SELECT
    NULLIF(TRIM(c.customer_id), ''),
    NULLIF(TRIM(c.customer_unique_id), ''),
    NULLIF(TRIM(c.customer_zip_code_prefix), ''),
    NULLIF(TRIM(c.customer_city), ''),
    NULLIF(TRIM(c.customer_state), ''),
    m.estado,
    m.regiao
FROM raw.customers c
LEFT JOIN (
    VALUES
        ('AC', 'Acre', 'Norte'),
        ('AL', 'Alagoas', 'Nordeste'),
        ('AP', 'Amapá', 'Norte'),
        ('AM', 'Amazonas', 'Norte'),
        ('BA', 'Bahia', 'Nordeste'),
        ('CE', 'Ceará', 'Nordeste'),
        ('DF', 'Distrito Federal', 'Centro-Oeste'),
        ('ES', 'Espírito Santo', 'Sudeste'),
        ('GO', 'Goiás', 'Centro-Oeste'),
        ('MA', 'Maranhão', 'Nordeste'),
        ('MT', 'Mato Grosso', 'Centro-Oeste'),
        ('MS', 'Mato Grosso do Sul', 'Centro-Oeste'),
        ('MG', 'Minas Gerais', 'Sudeste'),
        ('PA', 'Pará', 'Norte'),
        ('PB', 'Paraíba', 'Nordeste'),
        ('PR', 'Paraná', 'Sul'),
        ('PE', 'Pernambuco', 'Nordeste'),
        ('PI', 'Piauí', 'Nordeste'),
        ('RJ', 'Rio de Janeiro', 'Sudeste'),
        ('RN', 'Rio Grande do Norte', 'Nordeste'),
        ('RS', 'Rio Grande do Sul', 'Sul'),
        ('RO', 'Rondônia', 'Norte'),
        ('RR', 'Roraima', 'Norte'),
        ('SC', 'Santa Catarina', 'Sul'),
        ('SP', 'São Paulo', 'Sudeste'),
        ('SE', 'Sergipe', 'Nordeste'),
        ('TO', 'Tocantins', 'Norte')
) AS m(uf, estado, regiao)
    ON m.uf = NULLIF(TRIM(c.customer_state), '');

-- 03. AMOSTRA PÓS-TRANSFORMAÇÃO
SELECT *
FROM dw.dim_cliente
LIMIT 10;