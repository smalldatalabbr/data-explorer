-- NEXUS
-- DW
-- Transformação: Produto
-- ============================================================
/*
Origem:
    raw.products

Destino:
    dw.dim_produto

Grão:
    1 produto por registro

Responsabilidade:
    Representar o contexto de produto no modelo analítico.
*/

-- 01. RECRIAÇÃO DA TABELA
DROP TABLE IF EXISTS dw.dim_produto;

CREATE TABLE dw.dim_produto (
    produto_id              VARCHAR(32) NOT NULL,
    categoria                VARCHAR(100),
    peso_g                   INTEGER,
    comprimento_cm           SMALLINT,
    altura_cm                SMALLINT,
    largura_cm               SMALLINT,

    PRIMARY KEY (produto_id)
);

-- 02. TRANSFORMAÇÃO E CARGA
INSERT INTO dw.dim_produto (
    produto_id,
    categoria,
    peso_g,
    comprimento_cm,
    altura_cm,
    largura_cm
)
SELECT
    NULLIF(TRIM(product_id), ''),
    NULLIF(TRIM(product_category_name), ''),
    NULLIF(TRIM(product_weight_g), '')::INTEGER,
    NULLIF(TRIM(product_length_cm), '')::SMALLINT,
    NULLIF(TRIM(product_height_cm), '')::SMALLINT,
    NULLIF(TRIM(product_width_cm), '')::SMALLINT
FROM raw.products;

-- 03. AMOSTRA PÓS-TRANSFORMAÇÃO
SELECT *
FROM dw.dim_produto
LIMIT 10;
