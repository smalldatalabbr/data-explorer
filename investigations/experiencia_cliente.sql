/*
===============================================================================
INVESTIGAÇÃO: Experiência do Cliente

OBJETIVO:
Analisar a associação entre o cumprimento do prazo de entrega
e a experiência percebida pelo cliente, considerando as notas
atribuídas aos pedidos avaliados.

PERGUNTA:
Como o cumprimento do prazo de entrega está associado à
experiência percebida pelo cliente?

HIPÓTESES:

H1 — Comportamento de entrega e experiência do cliente
As notas médias dos pedidos apresentam diferenças entre as
categorias de comportamento de entrega.

H2 — Intensidade do desvio de entrega e experiência do cliente
A intensidade do atraso está associada a diferenças nas notas
médias e na distribuição das avaliações dos pedidos.

POPULAÇÃO:
Pedidos entregues com datas de compra, envio, entrega e entrega
estimada preenchidas e com avaliação do cliente disponível,
considerando os dados carregados a partir de 2017-01-01.

GRÃO:
- 1 pedido nas análises de comportamento e intensidade do desvio.
- 1 faixa de desvio de entrega nas análises agregadas.

MÉTRICAS:
- quantidade_pedidos
- nota_media
- percentual_nota_1
- percentual_notas_4_5
- dias_atraso

CRITÉRIOS:
- status = 'delivered'
- data_compra IS NOT NULL
- data_envio IS NOT NULL
- data_entrega IS NOT NULL
- data_entrega_estimada IS NOT NULL
- nota_avaliacao IS NOT NULL

OBSERVAÇÕES METODOLÓGICAS:
- O desvio de entrega corresponde à diferença entre a data de
  entrega e a data de entrega estimada.
- Valores negativos representam antecipação; zero representa
  entrega na data estimada; valores positivos representam atraso.
- A classificação geral distingue entregas antecipadas, na data
  prevista e atrasadas.
- As faixas de intensidade consideram o desvio de entrega, e não
  a duração total do ciclo operacional.
- A avaliação do cliente pode refletir diferentes aspectos da
  experiência, incluindo produto, vendedor e logística.
- As análises são descritivas e não estabelecem relações causais.
- A confiabilidade das datas registradas, especialmente em
  atrasos extremos, constitui uma limitação da análise.

===============================================================================
*/


-- =============================================================================
-- H1. COMPORTAMENTO DE ENTREGA E EXPERIÊNCIA DO CLIENTE
-- =============================================================================

-- H1.1 Comportamento de entrega e nota média

WITH base AS (
    SELECT
        fp.pedido_id,
        fp.dias_atraso,
        fr.nota
    FROM dw.fato_pedido AS fp
    JOIN dw.fato_review AS fr
        ON fp.pedido_id = fr.pedido_id
    WHERE fp.status = 'delivered'
      AND fp.data_entrega IS NOT NULL
      AND fp.data_entrega_estimada IS NOT NULL
)
SELECT
    CASE
        WHEN dias_atraso < 0 THEN 'Entrega antecipada'
        WHEN dias_atraso = 0 THEN 'Entrega na data prevista'
        ELSE 'Entrega com atraso'
    END AS comportamento_entrega,
    COUNT(*) AS total_pedidos,
    ROUND(AVG(nota), 2) AS nota_media
FROM base
GROUP BY 1
ORDER BY
    CASE
        WHEN MIN(dias_atraso) < 0
             AND MAX(dias_atraso) < 0 THEN 1
        WHEN MIN(dias_atraso) = 0
             AND MAX(dias_atraso) = 0 THEN 2
        ELSE 3
    END;


-- ============================================================
-- H2. INTENSIDADE DO ATRASO E EXPERIÊNCIA DO CLIENTE
-- ============================================================

-- H2.1 Intensidade do atraso × nota média

WITH review_pedidos AS (
    SELECT
        fp.pedido_id,
        fp.dias_atraso,
        fr.nota AS nota
    FROM dw.fato_pedido AS fp
    JOIN dw.fato_review AS fr
        ON fp.pedido_id = fr.pedido_id
    WHERE fp.status = 'delivered'
      AND fp.data_entrega IS NOT NULL
      AND fp.data_entrega_estimada IS NOT NULL
),

faixa_desvio_entrega AS (
    SELECT
        pedido_id,
        dias_atraso,

		CASE
            WHEN dias_atraso <= 0   THEN 'Sem atraso'
		    WHEN dias_atraso BETWEEN 1 AND 3 THEN 'Até 3 dias'
		    WHEN dias_atraso BETWEEN 4 AND 7 THEN '4–7 dias'
		    WHEN dias_atraso BETWEEN 8 AND 14 THEN '8–14 dias'
		    WHEN dias_atraso BETWEEN 15 AND 30 THEN '15–30 dias'
		    WHEN dias_atraso > 30 THEN 'Mais de 30 dias'
        END AS faixa_desvio_entrega,

        nota
    FROM review_pedidos
)

SELECT
    faixa_desvio_entrega,
    COUNT(*) AS total_pedidos,
    ROUND(AVG(nota), 2) AS nota_media
FROM faixa_desvio_entrega
GROUP BY faixa_desvio_entrega
ORDER BY total_pedidos DESC;



-- H2.2 Intensidade do atraso × distribuição das notas

WITH review_pedidos AS (
    SELECT
        fp.pedido_id,
        fp.dias_atraso,
        fr.nota AS nota
    FROM dw.fato_pedido AS fp
    JOIN dw.fato_review AS fr
        ON fp.pedido_id = fr.pedido_id
    WHERE fp.status = 'delivered'
      AND fp.data_entrega IS NOT NULL
      AND fp.data_entrega_estimada IS NOT NULL
),

faixa_desvio_entrega AS (
    SELECT
        pedido_id,
        dias_atraso,

		CASE
            WHEN dias_atraso <= 0   THEN 'Sem atraso'
		    WHEN dias_atraso BETWEEN 1 AND 3 THEN 'Até 3 dias'
		    WHEN dias_atraso BETWEEN 4 AND 7 THEN '4–7 dias'
		    WHEN dias_atraso BETWEEN 8 AND 14 THEN '8–14 dias'
		    WHEN dias_atraso BETWEEN 15 AND 30 THEN '15–30 dias'
		    WHEN dias_atraso > 30 THEN 'Mais de 30 dias'
        END AS faixa_desvio_entrega,

        nota
    FROM review_pedidos
)

SELECT
    faixa_desvio_entrega,
    COUNT(*) AS total_pedidos,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE nota = 1) / COUNT(*),
        2
    ) AS pct_nota_1,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE nota IN (4, 5)) / COUNT(*),
        2
    ) AS pct_nota_4_5

FROM faixa_desvio_entrega
GROUP BY faixa_desvio_entrega
ORDER BY total_pedidos DESC;
