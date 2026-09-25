-- NEXUS
-- DW
-- Transformação: Itens de Pedido
-- ============================================================
/*
Origem:
    raw.order_items

Destino:
    dw.fato_item_pedido

Grão:
    1 registro por item de pedido

Chave:
    (pedido_id, item_id)

Responsabilidade:
    Representar os itens associados aos pedidos, preservando produto, vendedor e valores da transação.
*/

-- 01. RECRIAÇÃO DA TABELA
DROP TABLE IF EXISTS dw.fato_item_pedido;

CREATE TABLE dw.fato_item_pedido (
    pedido_id          VARCHAR(32) NOT NULL,
    item_id            SMALLINT NOT NULL,
    produto_id         VARCHAR(32) NOT NULL,
    vendedor_id        VARCHAR(32) NOT NULL,
    data_limite_envio  DATE NOT NULL,
    preco              NUMERIC(10,2) NOT NULL,
    frete              NUMERIC(10,2) NOT NULL,

    PRIMARY KEY (pedido_id, item_id),

    FOREIGN KEY (pedido_id)
        REFERENCES dw.fato_pedido(pedido_id),

    FOREIGN KEY (produto_id)
        REFERENCES dw.dim_produto(produto_id),

    FOREIGN KEY (vendedor_id)
        REFERENCES dw.dim_vendedor(vendedor_id)
);

-- 02. TRANSFORMAÇÃO E CARGA
INSERT INTO dw.fato_item_pedido (
    pedido_id,
    item_id,
    produto_id,
    vendedor_id,
    data_limite_envio,
    preco,
    frete
)
SELECT
    NULLIF(TRIM(order_id), ''),
    CAST(order_item_id AS SMALLINT),
    NULLIF(TRIM(product_id), ''),
    NULLIF(TRIM(seller_id), ''),
    shipping_limit_date::DATE,
    price::NUMERIC(10,2),
    freight_value::NUMERIC(10,2)
FROM raw.order_items;

-- 03. AMOSTRA PÓS-TRANSFORMAÇÃO
SELECT *
FROM dw.fato_item_pedido
LIMIT 10;
