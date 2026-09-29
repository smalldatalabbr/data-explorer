# Volume e Estabilidade Operacional

## Objetivo

Investigar a evolução do volume de pedidos entregues, sua relação com o prazo médio de entrega e o comportamento da variabilidade desses prazos ao longo do tempo.

A análise busca identificar padrões temporais e compreender se as variações no volume estão associadas a mudanças no desempenho e na estabilidade operacional.

## Escopo da análise

**Pergunta principal**

Como o volume de pedidos se relaciona com o prazo de entrega e como a variabilidade desses prazos se comporta ao longo do tempo?

**H1 — Volume e comportamento do prazo**

Investigar a evolução conjunta do volume de pedidos e do prazo médio de entrega, considerando tanto a associação global quanto as diferenças entre os anos analisados.

**H2 — Variabilidade dos prazos**

Analisar a dispersão dos prazos de entrega ao longo do tempo, identificando períodos com diferentes níveis de variabilidade absoluta e relativa.

## População e granularidade

* **População:** pedidos entregues, com data de entrega e data estimada de entrega preenchidas, considerando os dados carregados a partir de 01/01/2017.
* **Grão:** um pedido.
* **Métrica de desempenho:** `ciclo_operacional_dias`.

A análise utiliza os registros da `dw.fato_pedido`, sem necessidade de junções com a tabela de itens, preservando o grão original da fato.

## Abordagem analítica

A investigação é composta por quatro consultas, organizadas em duas frentes.

### H1 — Volume e comportamento do prazo

**H1.1 — Evolução mensal do volume e do prazo médio**

Compara a quantidade mensal de pedidos com o prazo médio de entrega. O objetivo é identificar como essas duas métricas evoluem ao longo do período e observar possíveis mudanças de comportamento.

**H1.2 — Associação global entre volume e prazo**

Calcula a correlação de Pearson entre o volume mensal de pedidos e o prazo médio de entrega. A consulta sintetiza a associação linear observada em todo o período, permitindo avaliar as limitações de uma medida agregada.

**H1.3 — Associação entre volume e prazo por ano**

Calcula a mesma correlação separadamente para cada ano. Essa abordagem permite observar diferenças temporais que podem não ser evidentes na análise global, considerando também a quantidade de meses disponíveis em cada período.

### H2 — Variabilidade dos prazos

**H2.1 — Evolução mensal da variabilidade dos prazos**

Analisa mensalmente o volume de pedidos, o prazo médio, o desvio-padrão e o coeficiente de variação (CV).

O desvio-padrão representa a dispersão absoluta dos prazos, enquanto o coeficiente de variação expressa essa dispersão em relação à média. A análise conjunta permite distinguir mudanças no nível médio dos prazos de mudanças em sua variabilidade relativa.

## Principais resultados

### Volume e comportamento do prazo

O volume mensal de pedidos cresceu significativamente ao longo de 2017 e permaneceu elevado nos meses analisados de 2018. O prazo médio, entretanto, apresentou oscilações expressivas, sem acompanhar uniformemente a evolução do volume.

A correlação global entre volume mensal e prazo médio foi praticamente nula (`r ≈ 0,003`).

Na análise anual, foram observados resultados distintos:

* **2017:** associação positiva fraca (`r ≈ 0,225`).
* **2018:** associação positiva moderada (`r ≈ 0,685`), considerando os oito meses disponíveis, de janeiro a agosto.

Esses resultados mostram que a associação observada depende do período considerado. A diferença entre as correlações anuais não demonstra, por si só, uma mudança estrutural na operação.

### Variabilidade dos prazos

O coeficiente de variação apresentou oscilações ao longo do período, variando aproximadamente entre 0,57 e 1,10.

Março de 2017 registrou a maior variabilidade relativa, com CV de aproximadamente 1,10. Em agosto de 2018, foi observado o menor valor, de aproximadamente 0,57, acompanhado de prazo médio de 7,66 dias e desvio-padrão de 4,37 dias.

A partir de abril de 2018, houve redução do prazo médio e da dispersão absoluta até agosto, enquanto o volume mensal permaneceu elevado.

Em boa parte do período, o coeficiente de variação permaneceu relativamente próximo, mesmo diante das oscilações no volume. Portanto, o crescimento da quantidade de pedidos não foi acompanhado por um aumento proporcional e contínuo da variabilidade relativa.

## Conclusão

A investigação demonstra que o volume mensal de pedidos, isoladamente, não explica o comportamento do prazo médio de entrega. A associação entre essas métricas variou conforme o período analisado, enquanto a variabilidade dos prazos apresentou oscilações próprias.

Os resultados também evidenciam que média, desvio-padrão e coeficiente de variação oferecem perspectivas complementares sobre o desempenho operacional. A análise conjunta dessas métricas permite identificar mudanças nos prazos e na sua dispersão sem atribuir causalidade às relações observadas.

## Implementação

As consultas utilizadas nesta investigação estão disponíveis no arquivo:

[`volume_estabilidade_operacional.sql`](./volume_estabilidade_operacional.sql)
