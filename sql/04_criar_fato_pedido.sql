-- NEXUS
-- DW
-- Transformação: Pedidos
-- ============================================================
/*
Origem:
    raw.orders

Destino:
    dw.fato_pedido

Grão:
    1 registro por pedido

Responsabilidade:
    Representar o processo de pedido no modelo analítico.

*/

-- 01. RECRIAÇÃO DA TABELA
DROP TABLE IF EXISTS dw.fato_pedido;

CREATE TABLE dw.fato_pedido (
    pedido_id              VARCHAR(32) NOT NULL,
    cliente_id             VARCHAR(32) NOT NULL,
    status                  VARCHAR(20) NOT NULL,
    data_compra             DATE NOT NULL,
    data_aprovacao          DATE,
    data_envio              DATE,
    data_entrega            DATE,
    data_entrega_estimada   DATE NOT NULL,

    PRIMARY KEY (pedido_id),

    FOREIGN KEY (cliente_id)
        REFERENCES dw.dim_cliente(cliente_id)
);

-- 02. TRANSFORMAÇÃO E CARGA
INSERT INTO dw.fato_pedido (
    pedido_id,
    cliente_id,
    status,
    data_compra,
    data_aprovacao,
    data_envio,
    data_entrega,
    data_entrega_estimada
)
SELECT
    NULLIF(TRIM(order_id), ''),
    NULLIF(TRIM(customer_id), ''),
    NULLIF(TRIM(order_status), ''),
    order_purchase_timestamp::DATE,
    order_approved_at::DATE,
    order_delivered_carrier_date::DATE,
    order_delivered_customer_date::DATE,
    order_estimated_delivery_date::DATE
FROM raw.orders;

-- 03. AMOSTRA PÓS-TRANSFORMAÇÃO
SELECT *
FROM dw.fato_pedido
LIMIT 10;
