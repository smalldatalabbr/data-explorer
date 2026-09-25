-- NEXUS
-- DW
-- Enriquecimento: Fato Pedido
-- ============================================================
/*
OBJETIVO:
Consolidar a dw.fato_pedido para o período analítico
definido no projeto e adicionar atributos derivados
relacionados ao ciclo operacional e ao cumprimento
do prazo de entrega.

ESCOPO TEMPORAL:
Pedidos com data_compra a partir de 01/01/2017.

JUSTIFICATIVA DA EXCLUSÃO TEMPORAL:
Os pedidos anteriores a 01/01/2017 pertencem ao início do
período disponível na fonte e apresentaram maior potencial
de introduzir ruído nas análises realizadas. Como o escopo
analítico consolidado do projeto foi definido a partir de
01/01/2017, esses registros serão removidos da DW analítica.

JUSTIFICATIVA DA EXCLUSÃO DE ANOMALIAS TEMPORAIS:
Foram identificados registros com inconsistências na sequência
temporal esperada do processo operacional, nos quais a data de
envio ocorre antes da data de compra ou a data de entrega ocorre
antes da data de envio. Esses registros não representam de forma
coerente o ciclo operacional e, portanto, serão removidos da DW
analítica. Os dados originais permanecem preservados na camada raw.

IMPORTANTE:
As remoções ocorrem somente na DW. A camada raw permanece
íntegra, preservando os dados originais da fonte.

ORDEM DE EXECUÇÃO:
	1. Remover reviews dos pedidos fora do período
	2. Remover itens dos pedidos fora do período
	3. Remover pedidos fora do período
	4. Remover reviews dos pedidos com anomalias temporais
	5. Remover itens dos pedidos com anomalias temporais
	6. Remover pedidos com anomalias temporais
	7. Adicionar atributos derivados à fato_pedido
	8. Preencher os atributos derivados
	9. Validar o resultado
*/

-- 01. REMOVER REVIEWS DE PEDIDOS FORA DO PERÍODO ANALÍTICO
DELETE FROM dw.fato_review fr
WHERE fr.pedido_id IN (
    SELECT fp.pedido_id
    FROM dw.fato_pedido fp
    WHERE fp.data_compra < DATE '2017-01-01'
);


-- 02. REMOVER ITENS DE PEDIDOS FORA DO PERÍODO ANALÍTICO
DELETE FROM dw.fato_item_pedido fi
WHERE fi.pedido_id IN (
    SELECT fp.pedido_id
    FROM dw.fato_pedido fp
    WHERE fp.data_compra < DATE '2017-01-01'
);


-- 03. REMOVER PEDIDOS FORA DO PERÍODO ANALÍTICO
DELETE FROM dw.fato_pedido
WHERE data_compra < DATE '2017-01-01';


-- 04. REMOVER REVIEWS DE PEDIDOS COM ANOMALIAS TEMPORAIS
DELETE FROM dw.fato_review fr
WHERE fr.pedido_id IN (
    SELECT fp.pedido_id
    FROM dw.fato_pedido fp
    WHERE
           (fp.data_envio IS NOT NULL
            AND fp.data_envio < fp.data_compra)
        OR (fp.data_entrega IS NOT NULL
            AND fp.data_envio IS NOT NULL
            AND fp.data_entrega < fp.data_envio)
);


-- 05. REMOVER ITENS DE PEDIDOS COM ANOMALIAS TEMPORAIS
DELETE FROM dw.fato_item_pedido fi
WHERE fi.pedido_id IN (
    SELECT fp.pedido_id
    FROM dw.fato_pedido fp
    WHERE
           (fp.data_envio IS NOT NULL
            AND fp.data_envio < fp.data_compra)
        OR (fp.data_entrega IS NOT NULL
            AND fp.data_envio IS NOT NULL
            AND fp.data_entrega < fp.data_envio)
);


-- 06. REMOVER PEDIDOS COM ANOMALIAS TEMPORAIS
DELETE FROM dw.fato_pedido
WHERE
       (data_envio IS NOT NULL
        AND data_envio < data_compra)
    OR (data_entrega IS NOT NULL
        AND data_envio IS NOT NULL
        AND data_entrega < data_envio);


-- 07. ADICIONAR ATRIBUTOS DERIVADOS À FATO_PEDIDO
ALTER TABLE dw.fato_pedido
ADD COLUMN ciclo_operacional_dias INTEGER,
ADD COLUMN tempo_ate_envio_dias INTEGER,
ADD COLUMN tempo_envio_entrega_dias INTEGER,
ADD COLUMN dias_atraso INTEGER,
ADD COLUMN entrega_atrasada BOOLEAN;


-- 08. PREENCHER OS ATRIBUTOS DERIVADOS
UPDATE dw.fato_pedido
SET
    ciclo_operacional_dias =
        data_entrega - data_compra,

    tempo_ate_envio_dias =
        data_envio - data_compra,

    tempo_envio_entrega_dias =
        data_entrega - data_envio,

    dias_atraso =
        data_entrega - data_entrega_estimada,

    entrega_atrasada =
        data_entrega > data_entrega_estimada;


-- 09. VALIDAÇÕES

-- 09.1 Confirmar que não existem pedidos anteriores a 2017
SELECT COUNT(*) AS pedidos_anteriores_2017
FROM dw.fato_pedido
WHERE data_compra < DATE '2017-01-01';


-- 09.2 Confirmar que não existem pedidos entregues sem data de envio
SELECT COUNT(*) AS pedidos_entregues_sem_envio
FROM dw.fato_pedido
WHERE status = 'delivered'
  AND data_entrega IS NOT NULL
  AND data_envio IS NULL;


-- 09.3 Confirmar que não existem anomalias temporais
SELECT COUNT(*) AS anomalias_temporais_restantes
FROM dw.fato_pedido
WHERE
       (data_envio IS NOT NULL
        AND data_envio < data_compra)
    OR (data_entrega IS NOT NULL
        AND data_envio IS NOT NULL
        AND data_entrega < data_envio);


-- 09.4 Verificar preenchimento das novas métricas
SELECT
    COUNT(*) AS total_pedidos,
    COUNT(ciclo_operacional_dias) AS ciclo_preenchido,
    COUNT(tempo_ate_envio_dias) AS envio_preenchido,
    COUNT(tempo_envio_entrega_dias) AS entrega_preenchida,
    COUNT(dias_atraso) AS atraso_preenchido,
    COUNT(entrega_atrasada) AS flag_atraso_preenchida
FROM dw.fato_pedido;


-- 09.5 Verificar integridade dos relacionamentos
SELECT COUNT(*) AS itens_sem_pedido
FROM dw.fato_item_pedido fi
LEFT JOIN dw.fato_pedido fp
    ON fp.pedido_id = fi.pedido_id
WHERE fp.pedido_id IS NULL;


SELECT COUNT(*) AS reviews_sem_pedido
FROM dw.fato_review fr
LEFT JOIN dw.fato_pedido fp
    ON fp.pedido_id = fr.pedido_id
WHERE fp.pedido_id IS NULL;
