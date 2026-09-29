# Comportamento do Ciclo Operacional

## Objetivo

Investigar a distribuição do ciclo operacional, o comportamento de seus componentes logísticos e as variações observadas ao longo do tempo.

A análise busca identificar como a duração do ciclo se relaciona com os tempos de expedição e transporte, além de compreender como esses componentes acompanham as mudanças no comportamento operacional.

## Escopo da análise

**Pergunta principal**

Como o ciclo operacional se comporta e quais componentes acompanham suas variações?

**H1 — Distribuição do ciclo operacional**

Investigar a distribuição dos pedidos conforme a duração do ciclo operacional, comparando os componentes logísticos e o cumprimento do prazo entre as diferentes faixas.

**H2 — Comportamento temporal do ciclo**

Analisar a evolução mensal do ciclo operacional e de seus componentes, identificando períodos de variação e observando como as alterações se manifestam ao longo do tempo.

## População e granularidade

* **População:** pedidos entregues, com datas de compra, envio, entrega e entrega estimada preenchidas, considerando os dados carregados a partir de 01/01/2017.
* **Grão:** um pedido nas análises por faixa e um mês nas análises temporais.
* **Métrica de desempenho:** `ciclo_operacional_dias`.

A análise utiliza os registros da `dw.fato_pedido`, sem necessidade de junções com a tabela de itens, preservando o grão original da fato.

## Abordagem analítica

A investigação é composta por cinco consultas, organizadas em duas frentes.

### H1 — Distribuição do ciclo operacional

**H1.1 — Distribuição do ciclo por faixa**

Classifica os pedidos em cinco faixas de duração do ciclo operacional: 0 a 6, 7 a 9, 10 a 14, 15 a 19 e mais de 20 dias. A consulta utiliza quantidade de pedidos, mediana, média e desvio-padrão para caracterizar a distribuição e a dispersão dos ciclos em cada faixa.

**H1.2 — Componentes logísticos por faixa**

Compara os tempos médios até o envio e entre o envio e a entrega nas diferentes faixas do ciclo operacional. O objetivo é identificar como os componentes logísticos variam conforme a duração total do ciclo.

**H1.3 — Cumprimento do prazo por faixa**

Analisa a quantidade e o percentual de pedidos atrasados em cada faixa do ciclo operacional. A consulta permite observar como os atrasos se distribuem entre os diferentes níveis de duração do ciclo.

### H2 — Comportamento temporal do ciclo

**H2.1 — Evolução mensal do ciclo e dos componentes**

Analisa a evolução mensal do volume de pedidos, do ciclo operacional médio e dos tempos médios até o envio e entre o envio e a entrega. A consulta permite observar as oscilações das métricas e identificar períodos com mudanças no comportamento operacional.

**H2.2 — Variações mensais do ciclo e dos componentes**

Calcula as diferenças entre as médias de meses consecutivos para o ciclo operacional e seus componentes. A análise complementa a evolução mensal ao evidenciar a direção e a magnitude das alterações observadas ao longo do período.

## Principais resultados

### Distribuição do ciclo operacional

A distribuição dos pedidos demonstra diferentes níveis de duração do ciclo operacional.

As três primeiras faixas, de 0 a 14 dias, concentram aproximadamente 71,3% dos pedidos, enquanto a faixa acima de 20 dias representa aproximadamente 15,4% do total.

Nas faixas intermediárias, as médias são próximas das medianas, indicando distribuições relativamente concentradas em torno dos valores centrais. Na faixa acima de 20 dias, a média é superior à mediana e o desvio-padrão é significativamente maior, evidenciando maior dispersão dos ciclos mais longos.

### Componentes logísticos por faixa

Os tempos médios de expedição e transporte aumentam conforme as faixas de duração do ciclo operacional se tornam mais longas.

O tempo médio até o envio passa de 1,63 dia na faixa de 0 a 6 dias para 5,79 dias na faixa acima de 20 dias. Já o tempo médio entre o envio e a entrega aumenta de 2,67 para 23,22 dias.

A diferença entre esses componentes evidencia que o transporte apresenta uma variação mais expressiva entre as faixas do que o tempo até o envio.

### Cumprimento do prazo por faixa

O percentual de pedidos atrasados aumenta progressivamente nas faixas mais longas do ciclo operacional.

Nas quatro primeiras faixas, os percentuais de atraso variam de 0,21% a 2,73%. Na faixa acima de 20 dias, esse percentual chega a 38,89%.

Essa última faixa concentra 5.765 pedidos atrasados, aproximadamente 88,3% do total de atrasos observado.

Os resultados evidenciam uma associação entre ciclos mais longos e maior ocorrência de atrasos. Entretanto, a duração do ciclo e os dias de atraso representam métricas distintas e não devem ser interpretados como equivalentes.

### Comportamento temporal do ciclo

A evolução mensal apresenta oscilações expressivas ao longo do período analisado.

Durante 2017, o ciclo operacional apresentou variações, com elevações em abril, novembro e dezembro. O período entre novembro de 2017 e março de 2018 concentrou valores elevados, com média de 16,87 dias em fevereiro de 2018.

A partir de abril de 2018, o ciclo apresentou redução contínua, alcançando 7,66 dias em agosto, mesmo com o volume mensal de pedidos permanecendo elevado.

O tempo entre o envio e a entrega acompanhou boa parte das oscilações do ciclo, enquanto o tempo até o envio apresentou variações relativamente menores.

### Variações mensais do ciclo e dos componentes

A análise das variações mensais evidencia mudanças expressivas na duração do ciclo operacional e de seus componentes.

Em novembro de 2017, o ciclo apresentou aumento de 3,34 dias em relação ao mês anterior. Em fevereiro de 2018, ocorreu novo aumento, de 2,86 dias.

Em abril de 2018, foi observada uma redução de 4,82 dias, seguida por novas quedas até agosto do mesmo ano.

As variações do tempo entre o envio e a entrega acompanharam a direção das mudanças do ciclo na maioria dos meses e apresentaram magnitudes superiores às observadas no tempo até o envio.

Esses resultados complementam a evolução mensal, destacando a intensidade das mudanças entre períodos consecutivos.

## Conclusão

A investigação demonstra que o ciclo operacional apresenta diferentes padrões de duração e variação ao longo do período analisado.

Nas análises por faixa, os ciclos mais longos estão associados a maiores tempos médios de expedição e, principalmente, de transporte. Também foi observada uma concentração expressiva de atrasos na faixa acima de 20 dias.

Na perspectiva temporal, o ciclo apresentou oscilações relevantes, com elevação entre o final de 2017 e o início de 2018, seguida por uma redução contínua até agosto de 2018. O tempo entre o envio e a entrega acompanhou boa parte dessas mudanças, enquanto o tempo até o envio apresentou variações menores.

Em conjunto, os resultados permitem caracterizar o comportamento do ciclo operacional e identificar os componentes que acompanham suas variações. As análises são descritivas e não estabelecem relações causais, especialmente considerando a dependência matemática entre o ciclo e seus componentes.

## Implementação

As consultas utilizadas nesta investigação estão disponíveis no arquivo:

[`comportamento_ciclo_operacional.sql`](./comportamento_ciclo_operacional.sql)
