# Contexto do Comportamento Logístico

## Objetivo

Analisar como o comportamento logístico varia de acordo com as características geográficas da operação, considerando as regiões, os estados e as rotas de origem e destino dos pedidos.

## Escopo da análise

**Pergunta principal:** Quais características geográficas da operação estão associadas a diferentes padrões de comportamento logístico?

**Hipóteses:**

* **H1 — Comportamento geral das entregas:** a distribuição de entregas antecipadas, realizadas na data prevista e atrasadas apresenta diferentes proporções.
* **H2 — Comportamento por região de destino:** as regiões de destino apresentam diferenças nos padrões de comportamento das entregas e nos tempos das etapas logísticas.
* **H3 — Comportamento por estado de destino:** existem diferenças entre os estados nos padrões de comportamento das entregas e nos tempos das etapas logísticas.
* **H4 — Comportamento por rota:** as combinações entre regiões de origem e destino apresentam diferentes padrões de comportamento das entregas e nos tempos das etapas logísticas.

## População e granularidade

A população é composta por pedidos entregues, com datas de envio, entrega e entrega estimada preenchidas, totalizando 96.184 pedidos.

A análise considera cada pedido como unidade de observação, com exceção da análise por rota, que contempla apenas pedidos cuja origem pode ser associada a uma única região.

O comportamento logístico é classificado em três categorias, com base na diferença entre a data de entrega e a data estimada:

* **Antecipada:** entrega realizada antes da data estimada.
* **Na data prevista:** entrega realizada exatamente na data estimada.
* **Com atraso:** entrega realizada após a data estimada.

## Abordagem analítica

### H1 — Comportamento geral das entregas

**Classificação do comportamento logístico**

Classificação dos pedidos em três categorias, considerando a quantidade e a proporção de entregas antecipadas, realizadas na data prevista e atrasadas. A consulta também identifica os intervalos observados de antecipação e atraso.

### H2 — Comportamento por região de destino

**Distribuição do comportamento logístico por região**

Comparação das proporções de entregas antecipadas, realizadas na data prevista e atrasadas entre as regiões brasileiras de destino. A análise também considera os tempos médios até o envio e entre o envio e a entrega.

### H3 — Comportamento por estado de destino

**Distribuição do comportamento logístico por estado**

Detalhamento das diferenças entre os estados de destino, considerando a distribuição dos três comportamentos logísticos e os tempos médios das etapas de envio e transporte.

### H4 — Comportamento por rota

**Distribuição do comportamento logístico por rota de origem e destino**

Comparação das combinações entre regiões de origem e destino, considerando as proporções de cada comportamento logístico e os tempos médios das etapas operacionais. A análise contempla somente rotas com uma única região de origem identificada.

## Principais resultados

### H1 — Comportamento geral das entregas

Dos 96.184 pedidos analisados, 88.363 (91,87%) foram entregues antecipadamente, 1.291 (1,34%) na data prevista e 6.530 (6,79%) com atraso.

A antecipação foi, portanto, o comportamento predominante. Apesar disso, a proporção de entregas atrasadas representa uma parcela relevante da população analisada.

As magnitudes dos desvios também apresentaram diferenças: as antecipações variaram de 1 a 147 dias, enquanto os atrasos variaram de 1 a 188 dias.

### H2 — Comportamento por região de destino

As regiões apresentaram diferenças tanto nos tempos de transporte quanto nas proporções de entregas atrasadas.

O Sudeste concentrou o maior volume, com 66.004 pedidos, e apresentou o menor tempo médio entre envio e entrega, de 7,50 dias. O Norte registrou o maior tempo médio nessa etapa, de 19,23 dias, enquanto o Nordeste apresentou a maior proporção de atrasos, de 12,76%.

O tempo médio até o envio permaneceu relativamente estável entre as regiões, variando de 3,13 a 3,31 dias. Em contrapartida, o tempo médio entre envio e entrega apresentou variação consideravelmente maior.

Os resultados indicam que o comportamento das entregas varia entre as regiões e que tempos de transporte mais elevados não correspondem necessariamente às maiores proporções de atraso.

### H3 — Comportamento por estado de destino

A análise por estado evidenciou diferenças que não ficam totalmente visíveis na comparação regional.

São Paulo concentrou o maior volume, com 40.387 pedidos, e apresentou tempo médio de transporte de 5,56 dias e proporção de atrasos de 4,50%.

Entre os estados com volumes expressivos, Bahia apresentou 12,17% de atrasos, com tempo médio de transporte de 15,99 dias. Rio de Janeiro registrou 12,14% de atrasos e tempo médio de transporte de 11,97 dias.

Também foram observados estados com tempos médios de transporte elevados e proporções relativamente baixas de atraso, como Amazonas, com 23,44 dias e 2,76%, respectivamente.

As diferenças observadas reforçam a importância de analisar os estados individualmente, considerando também o volume de pedidos de cada localidade. Resultados de estados com amostras pequenas devem ser interpretados com cautela.

### H4 — Comportamento por rota

A análise das rotas revelou diferenças entre as combinações de regiões de origem e destino, tanto nos tempos de transporte quanto nas proporções de atraso.

A rota Sudeste → Sudeste concentrou o maior volume, com 56.056 pedidos, apresentando tempo médio de transporte de 7,16 dias e proporção de atrasos de 6,39%.

Entre as rotas com volumes mais expressivos, Sul → Nordeste apresentou 13,10% de atrasos, com 832 pedidos, enquanto Sudeste → Nordeste registrou 12,95%, com 7.561 pedidos. A rota Sudeste → Norte apresentou o maior tempo médio de transporte entre essas rotas, com 19,21 dias, e proporção de atrasos de 9,13%.

As rotas internas Sudeste → Sudeste e Sul → Sul apresentaram tempos médios de transporte próximos, de 7,16 e 7,40 dias, respectivamente, mas proporções de atraso diferentes, de 6,39% e 3,69%.

As rotas com volumes reduzidos exigem cautela na interpretação, pois pequenas quantidades de pedidos podem produzir percentuais pouco representativos.

## Conclusão

A investigação identificou diferenças no comportamento logístico conforme a região, o estado e a rota de destino dos pedidos.

Embora as entregas antecipadas predominem na população analisada, as proporções de atraso e os tempos de transporte variam entre as localidades e as combinações de origem e destino.

A análise por estado revelou diferenças internas às regiões, enquanto a análise por rota permitiu observar variações associadas às combinações geográficas da operação. Os resultados também mostram que tempos de transporte mais elevados não implicam, necessariamente, maiores proporções de atraso.

Essas evidências são descritivas e permitem caracterizar os padrões observados, mas não estabelecem relações causais entre localização e desempenho logístico. Além disso, as rotas com baixo volume devem ser interpretadas com cautela.

## Implementação

As consultas SQL utilizadas nesta investigação estão disponíveis em [`contexto_comportamento_logistico.sql`](contexto_comportamento_logistico.sql).
