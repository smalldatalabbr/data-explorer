/*
===============================================================================
INVESTIGAÇÃO: Volume e Estabilidade Operacional

OBJETIVO:
Analisar a evolução do volume de pedidos entregues, seu relacionamento
com o prazo de entrega e a variabilidade desses prazos ao longo do tempo.

PERGUNTA:
Como o volume de pedidos se relaciona com o prazo de entrega e como a
variabilidade desses prazos se comporta ao longo do tempo?

HIPÓTESES:

H1 — Volume e comportamento do prazo
A evolução do volume de pedidos não apresenta uma associação linear
uniforme com o prazo médio de entrega ao longo do período analisado.

H2 — Variabilidade dos prazos
A dispersão dos prazos de entrega apresenta diferentes níveis de
variabilidade ao longo do período analisado.

POPULAÇÃO:
Pedidos entregues, com data de entrega e data estimada de entrega
preenchidas, considerando os dados carregados a partir de 2017-01-01.

GRÃO:
1 pedido.

MÉTRICAS:
- quantidade_pedidos
- prazo_medio_entrega_dias
- desvio_padrao_prazo_dias
- coeficiente_variacao

CRITÉRIOS:
- status = 'delivered'
- data_entrega IS NOT NULL
- data_entrega_estimada IS NOT NULL

OBSERVAÇÕES METODOLÓGICAS:
- A análise considera o prazo operacional registrado em
  ciclo_operacional_dias.
- As agregações temporais são realizadas por mês de compra.
- O coeficiente de variação é calculado pela razão entre o
  desvio-padrão e a média, sem arredondamento intermediário.
- As correlações são calculadas sobre as agregações mensais.
- Os resultados são descritivos e não estabelecem relações causais.

===============================================================================
*/


-- ============================================================================
-- H1. VOLUME E COMPORTAMENTO DO PRAZO
-- ============================================================================


-- H1.1 Evolução mensal do volume e do prazo médio

SELECT
    DATE_TRUNC('month', data_compra)::date AS periodo,
    COUNT(*) AS quantidade_pedidos,
    ROUND(
        AVG(ciclo_operacional_dias),
        2
    ) AS prazo_medio_entrega_dias
FROM dw.fato_pedido
WHERE status = 'delivered'
  AND data_entrega IS NOT NULL
  AND data_entrega_estimada IS NOT NULL
GROUP BY periodo
ORDER BY periodo;


-- H1.2 Associação global entre volume e prazo médio

WITH dados_mensais AS (
    SELECT
        DATE_TRUNC('month', data_compra)::date AS periodo,
        COUNT(*) AS quantidade_pedidos,
        AVG(ciclo_operacional_dias) AS prazo_medio_entrega_dias
    FROM dw.fato_pedido
    WHERE status = 'delivered'
      AND data_entrega IS NOT NULL
      AND data_entrega_estimada IS NOT NULL
    GROUP BY periodo
)

SELECT
    CORR(
        quantidade_pedidos,
        prazo_medio_entrega_dias
    ) AS correlacao_volume_prazo
FROM dados_mensais;


-- H1.3 Associação entre volume e prazo médio por ano

WITH dados_mensais AS (
    SELECT
        DATE_TRUNC('month', data_compra)::date AS periodo,
        EXTRACT(YEAR FROM data_compra)::integer AS ano,
        COUNT(*) AS quantidade_pedidos,
        AVG(ciclo_operacional_dias) AS prazo_medio_entrega_dias
    FROM dw.fato_pedido
    WHERE status = 'delivered'
      AND data_entrega IS NOT NULL
      AND data_entrega_estimada IS NOT NULL
    GROUP BY periodo, ano
)

SELECT
    ano,
    CORR(
        quantidade_pedidos,
        prazo_medio_entrega_dias
    ) AS correlacao_volume_prazo
FROM dados_mensais
GROUP BY ano
ORDER BY ano;


-- ============================================================================
-- H2. VARIABILIDADE DOS PRAZOS
-- ============================================================================


-- H2.1 Evolução mensal da variabilidade dos prazos

WITH dados_mensais AS (
    SELECT
        DATE_TRUNC('month', data_compra)::date AS periodo,
        COUNT(*) AS quantidade_pedidos,
        AVG(ciclo_operacional_dias) AS prazo_medio_entrega_dias,
        STDDEV(ciclo_operacional_dias) AS desvio_padrao_prazo_dias
    FROM dw.fato_pedido
    WHERE status = 'delivered'
      AND data_entrega IS NOT NULL
      AND data_entrega_estimada IS NOT NULL
    GROUP BY periodo
)

SELECT
    periodo,
    quantidade_pedidos,
    ROUND(prazo_medio_entrega_dias, 2)
        AS prazo_medio_entrega_dias,
    ROUND(desvio_padrao_prazo_dias, 2)
        AS desvio_padrao_prazo_dias,
    ROUND(
        desvio_padrao_prazo_dias
        / NULLIF(prazo_medio_entrega_dias, 0),
        2
    ) AS coeficiente_variacao
FROM dados_mensais
ORDER BY periodo;