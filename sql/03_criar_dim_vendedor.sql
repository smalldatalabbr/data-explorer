-- NEXUS
-- DW
-- Transformação: Vendedor
-- ============================================================
/*
Origem:
    raw.sellers

Destino:
    dw.dim_vendedor

Grão:
    1 vendedor por registro

Responsabilidade:
    Representar o contexto de vendedor no modelo analítico.

Observação:
    O CEP é mantido como texto para preservar zeros à esquerda.
*/

-- 01. RECRIAÇÃO DA TABELA
DROP TABLE IF EXISTS dw.dim_vendedor;

CREATE TABLE dw.dim_vendedor (
    vendedor_id   VARCHAR(32) NOT NULL,
    cep           VARCHAR(5)  NOT NULL,
    cidade        VARCHAR(100) NOT NULL,
    uf            CHAR(2) NOT NULL,
    estado        VARCHAR(100),
    regiao        VARCHAR(20),

    PRIMARY KEY (vendedor_id)
);

-- 02. TRANSFORMAÇÃO E CARGA
INSERT INTO dw.dim_vendedor (
    vendedor_id,
    cep,
    cidade,
    uf,
    estado,
    regiao
)
SELECT
    NULLIF(TRIM(s.seller_id), ''),
    NULLIF(TRIM(s.seller_zip_code_prefix), ''),
    NULLIF(TRIM(s.seller_city), ''),
    NULLIF(TRIM(s.seller_state), ''),
    m.estado,
    m.regiao
FROM raw.sellers s
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
    ON m.uf = NULLIF(TRIM(s.seller_state), '');

-- 03. AMOSTRA PÓS-TRANSFORMAÇÃO
SELECT *
FROM dw.dim_vendedor
LIMIT 10;