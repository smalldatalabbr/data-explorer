/*
===============================================================================
INVESTIGAÇÃO: Comportamento do Ciclo Operacional

OBJETIVO:
Analisar a distribuição do ciclo operacional, o comportamento de seus
componentes e as variações observadas ao longo do período analisado.

PERGUNTA:
Como o ciclo operacional se comporta e quais componentes acompanham
suas variações?

HIPÓTESES:

H1 — Distribuição do ciclo operacional
Os pedidos apresentam diferentes níveis de duração do ciclo operacional,
com variações no comportamento dos componentes entre as faixas analisadas.

H2 — Comportamento temporal do ciclo
As variações mensais do ciclo operacional são acompanhadas por alterações
nos tempos de expedição e transporte, com diferentes magnitudes.

POPULAÇÃO:
Pedidos entregues, com datas de compra, envio, entrega e entrega estimada
preenchidas, considerando os dados carregados a partir de 2017-01-01.

GRÃO:
- 1 pedido nas análises por faixa.
- 1 mês nas análises temporais.

MÉTRICAS:
- quantidade_pedidos
- ciclo_operacional_dias
- tempo_ate_envio_dias
- tempo_envio_entrega_dias
- quantidade_atrasados
- percentual_atrasados
- delta_ciclo
- delta_ate_envio
- delta_envio_entrega

CRITÉRIOS:
- status = 'delivered'
- data_compra IS NOT NULL
- data_envio IS NOT NULL
- data_entrega IS NOT NULL
- data_entrega_estimada IS NOT NULL
- ciclo_operacional_dias IS NOT NULL

OBSERVAÇÕES METODOLÓGICAS:
- O ciclo operacional corresponde ao intervalo entre a compra e a entrega.
- Os componentes analisados correspondem aos intervalos até o envio e
  entre o envio e a entrega.
- As faixas são definidas a partir do ciclo operacional, e não dos dias
  de atraso.
- As agregações temporais são realizadas por mês de compra.
- As variações mensais são calculadas em relação ao mês disponível anterior,
  sem arredondamento intermediário.
- As análises são descritivas e não estabelecem relações causais.
- A relação entre o ciclo e seus componentes deve ser interpretada
  considerando a possível dependência matemática entre essas métricas.

===============================================================================
*/


-- ============================================================================
-- H1. DISTRIBUIÇÃO DO CICLO OPERACIONAL
-- ============================================================================


-- H1.1 Distribuição do ciclo por faixa

WITH classificacao_ciclo AS (
    SELECT
        ciclo_operacional_dias,
        CASE
            WHEN ciclo_operacional_dias < 7  THEN '0 a 6 dias'
            WHEN ciclo_operacional_dias < 10 THEN '7 a 9 dias'
            WHEN ciclo_operacional_dias < 15 THEN '10 a 14 dias'
            WHEN ciclo_operacional_dias < 20 THEN '15 a 19 dias'
            ELSE '+20 dias'
        END AS faixa
    FROM dw.fato_pedido
    WHERE status = 'delivered'
      AND data_envio IS NOT NULL
      AND data_entrega IS NOT NULL
      AND data_entrega_estimada IS NOT NULL
      AND ciclo_operacional_dias IS NOT NULL
)

SELECT
    faixa,
    COUNT(*) AS quantidade_pedidos,
    PERCENTILE_CONT(0.50)
        WITHIN GROUP (
            ORDER BY ciclo_operacional_dias
        ) AS mediana_ciclo_dias,
    ROUND(AVG(ciclo_operacional_dias), 2)
        AS media_ciclo_dias,
    ROUND(STDDEV(ciclo_operacional_dias), 2)
        AS desvio_padrao_ciclo_dias
FROM classificacao_ciclo
GROUP BY faixa
ORDER BY MIN(ciclo_operacional_dias);


-- H1.2 Componentes logísticos por faixa

WITH base AS (
    SELECT
        ciclo_operacional_dias,
        tempo_ate_envio_dias,
        tempo_envio_entrega_dias
    FROM dw.fato_pedido
    WHERE status = 'delivered'
      AND data_envio IS NOT NULL
      AND data_entrega IS NOT NULL
      AND data_entrega_estimada IS NOT NULL
      AND ciclo_operacional_dias IS NOT NULL
),

classificacao AS (
    SELECT
        ciclo_operacional_dias,
        tempo_ate_envio_dias,
        tempo_envio_entrega_dias,
        CASE
            WHEN ciclo_operacional_dias < 7  THEN '0 a 6 dias'
            WHEN ciclo_operacional_dias < 10 THEN '7 a 9 dias'
            WHEN ciclo_operacional_dias < 15 THEN '10 a 14 dias'
            WHEN ciclo_operacional_dias < 20 THEN '15 a 19 dias'
            ELSE '+20 dias'
        END AS faixa
    FROM base
)

SELECT
    faixa,
    ROUND(AVG(tempo_ate_envio_dias), 2)
        AS tempo_medio_ate_envio_dias,
    ROUND(AVG(tempo_envio_entrega_dias), 2)
        AS tempo_medio_envio_entrega_dias
FROM classificacao
GROUP BY faixa
ORDER BY MIN(ciclo_operacional_dias);


-- H1.3 Cumprimento do prazo por faixa

WITH base AS (
    SELECT
        ciclo_operacional_dias,
        CASE
            WHEN entrega_atrasada IS TRUE THEN 1
            ELSE 0
        END AS atrasado
    FROM dw.fato_pedido
    WHERE status = 'delivered'
      AND data_envio IS NOT NULL
      AND data_entrega IS NOT NULL
      AND data_entrega_estimada IS NOT NULL
      AND ciclo_operacional_dias IS NOT NULL
),

classificacao AS (
    SELECT
        ciclo_operacional_dias,
        atrasado,
        CASE
            WHEN ciclo_operacional_dias < 7  THEN '0 a 6 dias'
            WHEN ciclo_operacional_dias < 10 THEN '7 a 9 dias'
            WHEN ciclo_operacional_dias < 15 THEN '10 a 14 dias'
            WHEN ciclo_operacional_dias < 20 THEN '15 a 19 dias'
            ELSE '+20 dias'
        END AS faixa
    FROM base
)

SELECT
    faixa,
    COUNT(*) AS quantidade_pedidos,
    COUNT(*) FILTER (
        WHERE atrasado = 1
    ) AS quantidade_atrasados,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE atrasado = 1)
        / NULLIF(COUNT(*), 0),
        2
    ) AS percentual_atrasados
FROM classificacao
GROUP BY faixa
ORDER BY MIN(ciclo_operacional_dias);


-- ============================================================================
-- H2 — COMPORTTAMENTO TEMPORAL DO CICLO
-- ============================================================================


-- H2.1 — Evolução mensal do ciclo e dos componentes

WITH base_mensal AS (
    SELECT
        DATE_TRUNC('month', data_compra)::date AS periodo,
        COUNT(*) AS quantidade_pedidos,
        AVG(ciclo_operacional_dias) AS ciclo_medio,
        AVG(tempo_ate_envio_dias) AS tempo_medio_ate_envio,
        AVG(tempo_envio_entrega_dias) AS tempo_medio_envio_entrega
    FROM dw.fato_pedido
    WHERE status = 'delivered'
      AND data_compra IS NOT NULL
      AND data_envio IS NOT NULL
      AND data_entrega IS NOT NULL
      AND data_entrega_estimada IS NOT NULL
      AND ciclo_operacional_dias IS NOT NULL
    GROUP BY periodo
)

SELECT
    periodo,
    quantidade_pedidos,
    ROUND(ciclo_medio, 2) AS ciclo_medio_dias,
    ROUND(tempo_medio_ate_envio, 2)
        AS tempo_medio_ate_envio_dias,
    ROUND(tempo_medio_envio_entrega, 2)
        AS tempo_medio_envio_entrega_dias
FROM base_mensal
ORDER BY periodo;


-- H2.2 — Variações mensais do ciclo e dos componentes

WITH base_mensal AS (
    SELECT
        DATE_TRUNC('month', data_compra)::date AS periodo,
        AVG(ciclo_operacional_dias) AS ciclo_medio,
        AVG(tempo_ate_envio_dias) AS tempo_medio_ate_envio,
        AVG(tempo_envio_entrega_dias) AS tempo_medio_envio_entrega
    FROM dw.fato_pedido
    WHERE status = 'delivered'
      AND data_compra IS NOT NULL
      AND data_envio IS NOT NULL
      AND data_entrega IS NOT NULL
      AND data_entrega_estimada IS NOT NULL
      AND ciclo_operacional_dias IS NOT NULL
    GROUP BY periodo
),

variacoes AS (
    SELECT
        periodo,
        ciclo_medio - LAG(ciclo_medio)
            OVER (ORDER BY periodo) AS delta_ciclo,
        tempo_medio_ate_envio - LAG(tempo_medio_ate_envio)
            OVER (ORDER BY periodo) AS delta_ate_envio,
        tempo_medio_envio_entrega - LAG(tempo_medio_envio_entrega)
            OVER (ORDER BY periodo) AS delta_envio_entrega
    FROM base_mensal
)

SELECT
    periodo,
    ROUND(delta_ciclo, 2) AS delta_ciclo,
    ROUND(delta_ate_envio, 2) AS delta_ate_envio,
    ROUND(delta_envio_entrega, 2) AS delta_envio_entrega
FROM variacoes
ORDER BY periodo;