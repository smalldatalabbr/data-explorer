/*
===============================================================================
INVESTIGAÇÃO: # Contexto do Comportamento Logístico

OBJETIVO:
Analisar como o comportamento logístico varia conforme as regiões de
destino, os estados e as rotas de origem e destino dos pedidos.

PERGUNTA:
Quais características geográficas e rotas estão associadas a diferentes
padrões de comportamento logístico?

HIPÓTESES:

H1 — Classificação do comportamento logístico
Os pedidos entregues apresentam diferentes proporções de antecipações,
entregas na data prevista e atrasos, com variações na magnitude dos desvios.

H2 — Comportamento logístico por região de destino
O comportamento logístico e os tempos de operação apresentam diferenças
entre as regiões de destino dos pedidos.

H3 — Comportamento logístico por estado de destino
O comportamento logístico e os tempos de operação apresentam diferenças
entre os estados de destino dos pedidos.

H4 — Comportamento logístico por rota
O comportamento logístico e os tempos de operação variam conforme as
regiões de origem e destino das rotas.

POPULAÇÃO:
Pedidos entregues, considerando as datas necessárias para cada análise.
As consultas por região e estado contemplam 96.184 pedidos com datas de
envio, entrega e entrega estimada preenchidas. A análise por rota contempla
apenas pedidos com uma única região de origem e uma única região de destino.

GRÃO:
- 1 pedido nas análises de comportamento geral, região, estado e rota.
- 1 tipo de desvio na análise exploratória de outliers.

MÉTRICAS:
- quantidade_pedidos
- percentual_pedidos
- pedidos_antecipados
- pedidos_na_data_prevista
- pedidos_atrasados
- percentual_antecipados
- percentual_na_data_prevista
- percentual_atrasados
- tempo_medio_ate_envio_dias
- tempo_medio_envio_entrega_dias
- menor_desvio_dias
- maior_desvio_dias
- p25_dias
- p75_dias
- iqr_dias
- limite_superior_dias
- total_outliers
- percentual_outliers
- maior_outlier_dias

CRITÉRIOS:
- status = 'delivered'
- data_entrega IS NOT NULL
- data_entrega_estimada IS NOT NULL
- data_envio IS NOT NULL nas análises geográficas.
- dias_atraso < 0: entrega antecipada.
- dias_atraso = 0: entrega na data prevista.
- dias_atraso > 0: entrega com atraso.
- Uma única região de origem e uma única região de destino na análise
  de rotas.
- Limite superior de outliers definido por P75 + 1,5 × IQR.

OBSERVAÇÕES METODOLÓGICAS:
- O comportamento logístico é classificado conforme a diferença entre
  a data de entrega e a data de entrega estimada.
- A antecipação corresponde a um desvio negativo, enquanto o atraso
  corresponde a um desvio positivo.
- As análises por região e estado utilizam a região e o estado do cliente
  como destino do pedido.
- A análise por rota considera a região do vendedor como origem e a
  região do cliente como destino.
- Pedidos com itens associados a vendedores de regiões diferentes são
  excluídos da análise de rotas, para preservar a atribuição de uma
  única origem por pedido.
- A população da análise de rotas é inferior à das análises por região
  e estado em razão desse critério de atribuição.
- A análise de outliers é exploratória e não implica exclusão de registros.
- A presença de outliers e sua influência sobre as médias devem ser
  avaliadas separadamente.
- As análises são descritivas e não estabelecem relações causais.
- Diferenças entre grupos devem ser interpretadas considerando seus
  respectivos volumes de pedidos e a cobertura da população.

===============================================================================
*/


-- ============================================================================
-- H1. CLASSIFICAÇÃO DO COMPORTAMENTO LOGÍSTICO
-- ============================================================================


-- H1.1 Classificação geral do comportamento logístico

WITH comportamento_entrega AS (
    SELECT
        fp.pedido_id,
        fp.dias_atraso,
        CASE
            WHEN fp.dias_atraso > 0
                THEN 'Entrega com atraso'
            WHEN fp.dias_atraso = 0
                THEN 'Entrega na data prevista'
            ELSE 'Entrega antecipada'
        END AS comportamento_entrega
    FROM dw.fato_pedido AS fp
    WHERE fp.status = 'delivered'
      AND fp.data_entrega IS NOT NULL
      AND fp.data_entrega_estimada IS NOT NULL
)

SELECT
    comportamento_entrega,
    COUNT(*) AS total_pedidos,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS percentual_pedidos,
    MIN(dias_atraso) AS menor_desvio_dias,
    MAX(dias_atraso) AS maior_desvio_dias
FROM comportamento_entrega
GROUP BY comportamento_entrega
ORDER BY total_pedidos DESC;


-- ============================================================================
-- H2. COMPORTAMENTO LOGÍSTICO POR REGIÃO DE DESTINO
-- ============================================================================


-- H2.1 Comportamento logístico por região de destino

WITH comportamento_regioes AS (
    SELECT
        fp.pedido_id,
        dc.regiao AS regiao_destino,
        fp.tempo_ate_envio_dias,
        fp.tempo_envio_entrega_dias,
        fp.dias_atraso
    FROM dw.fato_pedido AS fp
    JOIN dw.dim_cliente AS dc
        ON fp.cliente_id = dc.cliente_id
    WHERE fp.status = 'delivered'
      AND fp.data_entrega IS NOT NULL
      AND fp.data_entrega_estimada IS NOT NULL
      AND fp.data_envio IS NOT NULL
)

SELECT
    regiao_destino,
    COUNT(*) AS quantidade_pedidos,
    ROUND(
        AVG(tempo_ate_envio_dias),
        2
    ) AS tempo_medio_ate_envio_dias,
    ROUND(
        AVG(tempo_envio_entrega_dias),
        2
    ) AS tempo_medio_envio_entrega_dias,
    COUNT(*) FILTER (
        WHERE dias_atraso < 0
    ) AS pedidos_antecipados,
    COUNT(*) FILTER (
        WHERE dias_atraso = 0
    ) AS pedidos_na_data_prevista,
    COUNT(*) FILTER (
        WHERE dias_atraso > 0
    ) AS pedidos_atrasados,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE dias_atraso < 0
        ) / COUNT(*),
        2
    ) AS percentual_antecipados,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE dias_atraso = 0
        ) / COUNT(*),
        2
    ) AS percentual_na_data_prevista,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE dias_atraso > 0
        ) / COUNT(*),
        2
    ) AS percentual_atrasados
FROM comportamento_regioes
GROUP BY regiao_destino
ORDER BY quantidade_pedidos DESC;


-- ============================================================================
-- H3. COMPORTAMENTO LOGÍSTICO POR ESTADO DE DESTINO
-- ============================================================================


-- H3.1 Comportamento logístico por estado de destino

WITH comportamento_estados AS (
    SELECT
        fp.pedido_id,
        dc.estado AS estado_destino,
        fp.tempo_ate_envio_dias,
        fp.tempo_envio_entrega_dias,
        fp.dias_atraso
    FROM dw.fato_pedido AS fp
    JOIN dw.dim_cliente AS dc
        ON fp.cliente_id = dc.cliente_id
    WHERE fp.status = 'delivered'
      AND fp.data_envio IS NOT NULL
      AND fp.data_entrega IS NOT NULL
      AND fp.data_entrega_estimada IS NOT NULL
)

SELECT
    estado_destino,
    COUNT(*) AS quantidade_pedidos,
    ROUND(
        AVG(tempo_ate_envio_dias),
        2
    ) AS tempo_medio_ate_envio_dias,
    ROUND(
        AVG(tempo_envio_entrega_dias),
        2
    ) AS tempo_medio_envio_entrega_dias,
    COUNT(*) FILTER (
        WHERE dias_atraso < 0
    ) AS pedidos_antecipados,
    COUNT(*) FILTER (
        WHERE dias_atraso = 0
    ) AS pedidos_na_data_prevista,
    COUNT(*) FILTER (
        WHERE dias_atraso > 0
    ) AS pedidos_atrasados,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE dias_atraso < 0
        ) / COUNT(*),
        2
    ) AS percentual_antecipados,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE dias_atraso = 0
        ) / COUNT(*),
        2
    ) AS percentual_na_data_prevista,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE dias_atraso > 0
        ) / COUNT(*),
        2
    ) AS percentual_atrasados
FROM comportamento_estados
GROUP BY estado_destino
ORDER BY quantidade_pedidos DESC;


-- ============================================================================
-- H4. COMPORTAMENTO LOGÍSTICO POR ROTA
-- ============================================================================


-- H4.1 Comportamento logístico por rota (origem × destino)

WITH comportamento_rotas AS (
    SELECT
        fp.pedido_id,
        MIN(dv.regiao) AS regiao_origem,
        MIN(dc.regiao) AS regiao_destino,
        fp.tempo_ate_envio_dias,
        fp.tempo_envio_entrega_dias,
        fp.dias_atraso
    FROM dw.fato_pedido AS fp
    JOIN dw.fato_item_pedido AS fi
        ON fp.pedido_id = fi.pedido_id
    JOIN dw.dim_vendedor AS dv
        ON fi.vendedor_id = dv.vendedor_id
    JOIN dw.dim_cliente AS dc
        ON fp.cliente_id = dc.cliente_id
    WHERE fp.status = 'delivered'
      AND fp.data_envio IS NOT NULL
      AND fp.data_entrega IS NOT NULL
      AND fp.data_entrega_estimada IS NOT NULL
    GROUP BY fp.pedido_id
    HAVING COUNT(DISTINCT dv.regiao) = 1
       AND COUNT(DISTINCT dc.regiao) = 1
)

SELECT
    regiao_origem,
    regiao_destino,
    COUNT(*) AS quantidade_pedidos,
    ROUND(
        AVG(tempo_ate_envio_dias),
        2
    ) AS tempo_medio_ate_envio_dias,
    ROUND(
        AVG(tempo_envio_entrega_dias),
        2
    ) AS tempo_medio_envio_entrega_dias,
    COUNT(*) FILTER (
        WHERE dias_atraso < 0
    ) AS pedidos_antecipados,
    COUNT(*) FILTER (
        WHERE dias_atraso = 0
    ) AS pedidos_na_data_prevista,
    COUNT(*) FILTER (
        WHERE dias_atraso > 0
    ) AS pedidos_atrasados,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE dias_atraso < 0
        ) / COUNT(*),
        2
    ) AS percentual_antecipados,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE dias_atraso = 0
        ) / COUNT(*),
        2
    ) AS percentual_na_data_prevista,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE dias_atraso > 0
        ) / COUNT(*),
        2
    ) AS percentual_atrasados
FROM comportamento_rotas
GROUP BY
    regiao_origem,
    regiao_destino
ORDER BY
    regiao_origem,
    quantidade_pedidos DESC;


-- ============================================================================
-- ANÁLISE EXPLORATÓRIA — IDENTIFICAÇÃO DE DESVIOS EXTREMOS
-- ============================================================================


-- E.1 Identificação de desvios extremos de entrega

WITH desvios AS (
    SELECT
        CASE
            WHEN fp.dias_atraso < 0 THEN 'Antecipação'
            WHEN fp.dias_atraso > 0 THEN 'Atraso'
        END AS tipo_desvio,
        ABS(fp.dias_atraso)::NUMERIC AS magnitude_desvio_dias
    FROM dw.fato_pedido AS fp
    WHERE fp.status = 'delivered'
      AND fp.data_entrega IS NOT NULL
      AND fp.data_entrega_estimada IS NOT NULL
      AND fp.dias_atraso <> 0
),

quartis AS (
    SELECT
        tipo_desvio,
        COUNT(*) AS total_pedidos,
        PERCENTILE_CONT(0.25) WITHIN GROUP (
            ORDER BY magnitude_desvio_dias
        ) AS p25,
        PERCENTILE_CONT(0.75) WITHIN GROUP (
            ORDER BY magnitude_desvio_dias
        ) AS p75,
        MAX(magnitude_desvio_dias) AS maior_desvio_dias
    FROM desvios
    GROUP BY tipo_desvio
),

limites AS (
    SELECT
        *,
        p75 - p25 AS iqr
    FROM quartis
)

SELECT
    l.tipo_desvio,
    l.total_pedidos,
    ROUND(l.p25::NUMERIC, 2) AS p25_dias,
    ROUND(l.p75::NUMERIC, 2) AS p75_dias,
    ROUND(l.iqr::NUMERIC, 2) AS iqr_dias,
    ROUND(
        (l.p75 + 1.5 * l.iqr)::NUMERIC,
        2
    ) AS limite_superior_dias,
    COUNT(*) FILTER (
        WHERE d.magnitude_desvio_dias > l.p75 + 1.5 * l.iqr
    ) AS total_outliers,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE d.magnitude_desvio_dias > l.p75 + 1.5 * l.iqr
        ) / l.total_pedidos,
        2
    ) AS percentual_outliers,
    ROUND(
        MAX(d.magnitude_desvio_dias) FILTER (
            WHERE d.magnitude_desvio_dias > l.p75 + 1.5 * l.iqr
        ),
        2
    ) AS maior_outlier_dias
FROM limites AS l
JOIN desvios AS d
    ON d.tipo_desvio = l.tipo_desvio
GROUP BY
    l.tipo_desvio,
    l.total_pedidos,
    l.p25,
    l.p75,
    l.iqr
ORDER BY l.tipo_desvio;
