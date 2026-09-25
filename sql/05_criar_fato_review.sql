-- NEXUS
-- DW
-- Transformação: Reviews
-- ============================================================
/*
Origem:
    raw.order_reviews
    raw.orders

Destino:
    dw.fato_review

Grão:
    1 review selecionada por pedido

Chave:
    review_id

Responsabilidade:
    Representar a avaliação do cliente associada ao pedido,
    utilizando uma única review por pedido.

Regra de seleção:
    1. Quando houver mais de uma review para o mesmo pedido,
       selecionar a mais recente.
    2. Excluir review_id associado a mais de um pedido
       no conjunto selecionado.

Observação:
    A data da review não é utilizada como critério de validade
    em relação à data de entrega.
*/

-- 01. RECRIAÇÃO DA TABELA
DROP TABLE IF EXISTS dw.fato_review;

CREATE TABLE dw.fato_review (
    review_id           VARCHAR(32) NOT NULL,
    pedido_id           VARCHAR(32) NOT NULL,
    nota                SMALLINT NOT NULL,
    titulo_comentario   TEXT,
    mensagem_comentario TEXT,
    data_criacao        DATE NOT NULL,

    PRIMARY KEY (review_id),

    FOREIGN KEY (pedido_id)
        REFERENCES dw.fato_pedido(pedido_id),

    UNIQUE (pedido_id)
);

-- 02. TRANSFORMAÇÃO E SELEÇÃO
WITH reviews_base AS (
    SELECT
        NULLIF(TRIM(r.review_id), '') AS review_id,
        NULLIF(TRIM(r.order_id), '') AS pedido_id,
        r.review_score::SMALLINT AS nota,
        NULLIF(TRIM(r.review_comment_title), '') AS titulo_comentario,
        NULLIF(TRIM(r.review_comment_message), '') AS mensagem_comentario,
        r.review_creation_date::DATE AS data_criacao,

        ROW_NUMBER() OVER (
            PARTITION BY r.order_id
            ORDER BY r.review_creation_date DESC
        ) AS rn

    FROM raw.order_reviews r

    INNER JOIN dw.fato_pedido p
        ON p.pedido_id = NULLIF(TRIM(r.order_id), '')
),

reviews_selecionadas AS (
    SELECT
        review_id,
        pedido_id,
        nota,
        titulo_comentario,
        mensagem_comentario,
        data_criacao
    FROM reviews_base
    WHERE rn = 1
),

review_ids_duplicados AS (
    SELECT
        review_id
    FROM reviews_selecionadas
    GROUP BY review_id
    HAVING COUNT(DISTINCT pedido_id) > 1
)

INSERT INTO dw.fato_review (
    review_id,
    pedido_id,
    nota,
    titulo_comentario,
    mensagem_comentario,
    data_criacao
)
SELECT
    r.review_id,
    r.pedido_id,
    r.nota,
    r.titulo_comentario,
    r.mensagem_comentario,
    r.data_criacao

FROM reviews_selecionadas r

LEFT JOIN review_ids_duplicados d
    ON d.review_id = r.review_id

WHERE d.review_id IS NULL;

-- 03. AMOSTRA PÓS-TRANSFORMAÇÃO
SELECT *
FROM dw.fato_review
LIMIT 10;