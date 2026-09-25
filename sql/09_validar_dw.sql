-- ============================================================
-- NEXUS
-- DW
-- Validação DW
-- ============================================================
/*
Objetivo:
    Validar a integridade estrutural e a consistência básica
    da DW após a consolidação do modelo analítico.

Validações:
    01. Quantidade de registros
    02. Duplicidade de chaves
    03. Integridade das Foreign Keys
    04. Pedidos sem itens
    05. Pedidos sem review
    06. Período dos pedidos
    07. Distribuição dos status
    08. Preenchimento dos atributos derivados
    09. Consistência das datas
    10. Consistência dos cálculos derivados
*/

-- 01. QUANTIDADE DE REGISTROS
SELECT 'dim_cliente' AS tabela, COUNT(*) AS quantidade
FROM dw.dim_cliente

UNION ALL

SELECT 'dim_produto', COUNT(*)
FROM dw.dim_produto

UNION ALL

SELECT 'dim_vendedor', COUNT(*)
FROM dw.dim_vendedor

UNION ALL

SELECT 'fato_pedido', COUNT(*)
FROM dw.fato_pedido

UNION ALL

SELECT 'fato_item_pedido', COUNT(*)
FROM dw.fato_item_pedido

UNION ALL

SELECT 'fato_review', COUNT(*)
FROM dw.fato_review;

-- 02. DUPLICIDADE DE CHAVES
-- Cliente
SELECT
    'dim_cliente.cliente_id' AS chave,
    COUNT(*) AS duplicidades
FROM (
    SELECT cliente_id
    FROM dw.dim_cliente
    GROUP BY cliente_id
    HAVING COUNT(*) > 1
) x

UNION ALL

-- Produto
SELECT
    'dim_produto.produto_id',
    COUNT(*)
FROM (
    SELECT produto_id
    FROM dw.dim_produto
    GROUP BY produto_id
    HAVING COUNT(*) > 1
) x

UNION ALL

-- Vendedor
SELECT
    'dim_vendedor.vendedor_id',
    COUNT(*)
FROM (
    SELECT vendedor_id
    FROM dw.dim_vendedor
    GROUP BY vendedor_id
    HAVING COUNT(*) > 1
) x

UNION ALL

-- Pedido
SELECT
    'fato_pedido.pedido_id',
    COUNT(*)
FROM (
    SELECT pedido_id
    FROM dw.fato_pedido
    GROUP BY pedido_id
    HAVING COUNT(*) > 1
) x

UNION ALL

-- Item de pedido
SELECT
    'fato_item_pedido.(pedido_id,item_id)',
    COUNT(*)
FROM (
    SELECT pedido_id, item_id
    FROM dw.fato_item_pedido
    GROUP BY pedido_id, item_id
    HAVING COUNT(*) > 1
) x

UNION ALL

-- Review
SELECT
    'fato_review.review_id',
    COUNT(*)
FROM (
    SELECT review_id
    FROM dw.fato_review
    GROUP BY review_id
    HAVING COUNT(*) > 1
) x;

-- 03. INTEGRIDADE DAS FOREIGN KEYS
-- Pedidos sem cliente
SELECT COUNT(*) AS pedidos_sem_cliente
FROM dw.fato_pedido p
LEFT JOIN dw.dim_cliente c
    ON c.cliente_id = p.cliente_id
WHERE c.cliente_id IS NULL;

-- Itens sem pedido
SELECT COUNT(*) AS itens_sem_pedido
FROM dw.fato_item_pedido i
LEFT JOIN dw.fato_pedido p
    ON p.pedido_id = i.pedido_id
WHERE p.pedido_id IS NULL;

-- Itens sem produto
SELECT COUNT(*) AS itens_sem_produto
FROM dw.fato_item_pedido i
LEFT JOIN dw.dim_produto p
    ON p.produto_id = i.produto_id
WHERE p.produto_id IS NULL;

-- Itens sem vendedor
SELECT COUNT(*) AS itens_sem_vendedor
FROM dw.fato_item_pedido i
LEFT JOIN dw.dim_vendedor v
    ON v.vendedor_id = i.vendedor_id
WHERE v.vendedor_id IS NULL;

-- Reviews sem pedido
SELECT COUNT(*) AS reviews_sem_pedido
FROM dw.fato_review r
LEFT JOIN dw.fato_pedido p
    ON p.pedido_id = r.pedido_id
WHERE p.pedido_id IS NULL;

-- 04. PEDIDOS SEM ITENS
SELECT COUNT(*) AS pedidos_sem_itens
FROM dw.fato_pedido p
LEFT JOIN dw.fato_item_pedido i
    ON i.pedido_id = p.pedido_id
WHERE i.pedido_id IS NULL;

SELECT
    p.status,
    COUNT(*) AS quantidade
FROM dw.fato_pedido p
LEFT JOIN dw.fato_item_pedido i
    ON i.pedido_id = p.pedido_id
WHERE i.pedido_id IS NULL
GROUP BY p.status
ORDER BY quantidade DESC;

-- 05. PEDIDOS SEM REVIEW
SELECT COUNT(*) AS pedidos_sem_review
FROM dw.fato_pedido p
LEFT JOIN dw.fato_review r
    ON r.pedido_id = p.pedido_id
WHERE r.pedido_id IS NULL;

-- 06. PERÍODO DOS PEDIDOS
SELECT
    MIN(data_compra) AS primeira_compra,
    MAX(data_compra) AS ultima_compra
FROM dw.fato_pedido;

-- 07. DISTRIBUIÇÃO DOS STATUS
SELECT
    status,
    COUNT(*) AS quantidade
FROM dw.fato_pedido
GROUP BY status
ORDER BY quantidade DESC;

-- 08. PREENCHIMENTO DOS ATRIBUTOS DERIVADOS
SELECT
    COUNT(*) AS total_pedidos,
    COUNT(ciclo_operacional_dias) AS ciclo_preenchido,
    COUNT(tempo_ate_envio_dias) AS envio_preenchido,
    COUNT(tempo_envio_entrega_dias) AS entrega_preenchida,
    COUNT(dias_atraso) AS atraso_preenchido,
    COUNT(entrega_atrasada) AS flag_atraso_preenchida
FROM dw.fato_pedido;

-- 09. CONSISTÊNCIA DAS DATAS
-- Entregas anteriores ao envio
SELECT COUNT(*) AS entregas_antes_do_envio
FROM dw.fato_pedido
WHERE data_envio IS NOT NULL
  AND data_entrega IS NOT NULL
  AND data_entrega < data_envio;

-- Envios anteriores à compra
SELECT COUNT(*) AS envios_antes_da_compra
FROM dw.fato_pedido
WHERE data_envio IS NOT NULL
  AND data_envio < data_compra;

-- Entregas anteriores à compra
SELECT COUNT(*) AS entregas_antes_da_compra
FROM dw.fato_pedido
WHERE data_entrega IS NOT NULL
  AND data_entrega < data_compra;

-- 10. CONSISTÊNCIA DOS CÁLCULOS DERIVADOS
-- O ciclo operacional deve ser igual à soma dos dois intervalos que o compõem.
SELECT COUNT(*) AS ciclos_inconsistentes
FROM dw.fato_pedido
WHERE ciclo_operacional_dias IS NOT NULL
  AND tempo_ate_envio_dias IS NOT NULL
  AND tempo_envio_entrega_dias IS NOT NULL
  AND ciclo_operacional_dias <>
      tempo_ate_envio_dias + tempo_envio_entrega_dias;

-- Verificar consistência do indicador de atraso
SELECT COUNT(*) AS flags_atraso_inconsistentes
FROM dw.fato_pedido
WHERE entrega_atrasada IS DISTINCT FROM (
    data_entrega > data_entrega_estimada
);