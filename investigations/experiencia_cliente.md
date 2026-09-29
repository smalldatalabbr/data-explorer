# Investigação 4 — Experiência do Cliente

## Objetivo

Analisar a associação entre o cumprimento do prazo de entrega e a experiência percebida pelo cliente, considerando as notas atribuídas aos pedidos avaliados e a intensidade dos desvios em relação à data estimada.

## Escopo da análise

**Pergunta principal:**

Como o cumprimento do prazo de entrega está associado à experiência percebida pelo cliente?

**Hipóteses:**

* **H1 — Comportamento de entrega e experiência do cliente:** as notas médias dos pedidos apresentam diferenças entre as categorias de comportamento de entrega (antecipada, na data prevista e atrasada).
* **H2 — Intensidade do desvio de entrega e experiência do cliente:** a intensidade do atraso está associada a diferenças nas notas médias e na distribuição das avaliações dos pedidos.

A investigação concentra-se na relação entre o comportamento de entrega e as avaliações dos clientes, sem buscar atribuir exclusivamente à logística as diferenças observadas nas notas.

## População e granularidade

A população analítica compreende **94.525 pedidos entregues com avaliação disponível**, considerando os registros com datas de compra, envio, entrega e entrega estimada preenchidas.

* **Unidade de análise:** pedido.
* **Granularidade das análises:** comportamento de entrega e faixas de intensidade do desvio.
* **Período:** conforme os dados disponíveis a partir de 2017-01-01.

As análises consideram apenas pedidos entregues que atendem aos critérios de preenchimento das datas e possuem nota de avaliação válida.

## Abordagem analítica

### H1 — Comportamento de entrega e experiência do cliente

**H1.1 — Comportamento de entrega e nota média**

Classifica os pedidos em três categorias — antecipada, na data prevista e atrasada — e compara a quantidade de pedidos e as respectivas notas médias. O objetivo é identificar diferenças na avaliação dos clientes entre os grupos de comportamento de entrega.

### H2 — Intensidade do desvio de entrega e experiência do cliente

**H2.1 — Intensidade do desvio de entrega e nota média**

Agrupa os pedidos conforme a intensidade do desvio em relação à data estimada, utilizando as seguintes faixas:

* Sem atraso;
* Até 3 dias;
* 4–7 dias;
* 8–14 dias;
* 15–30 dias;
* Mais de 30 dias.

Para cada faixa, calcula a quantidade de pedidos e a nota média, permitindo observar como as avaliações se distribuem conforme a intensidade do atraso.

**H2.2 — Intensidade do desvio de entrega e distribuição das notas**

Complementa a análise anterior, considerando a proporção de avaliações com nota 1 e a proporção de avaliações com notas 4 e 5 em cada faixa de desvio. Essa abordagem permite observar diferenças na distribuição das avaliações, além das variações na nota média.

## Principais resultados

### H1 — Comportamento de entrega e experiência do cliente

A comparação entre o comportamento de entrega e a nota média revelou diferenças nas avaliações dos pedidos:

| Comportamento de entrega |    Pedidos | Nota média |
| ------------------------ | ---------: | ---------: |
| Antecipada               |     86.957 |       4,30 |
| Na data prevista         |      1.264 |       4,04 |
| Atrasada                 |      6.304 |       2,27 |
| **Total**                | **94.525** |          — |

As entregas antecipadas apresentaram nota média de 4,30, enquanto as entregas na data prevista registraram 4,04. Para os pedidos atrasados, a nota média foi de 2,27.

A diferença observada indica uma associação entre o comportamento de entrega e a avaliação do cliente. Entretanto, as notas não devem ser interpretadas como uma medida exclusiva do desempenho logístico, pois também podem refletir aspectos relacionados ao produto e ao vendedor.

### H2 — Intensidade do desvio de entrega e experiência do cliente

**H2.1 — Intensidade do desvio de entrega e nota média**

A análise da nota média por faixa de desvio apresentou os seguintes resultados:

| Faixa de desvio |    Pedidos | Nota média |
| --------------- | ---------: | ---------: |
| Sem atraso      |     88.218 |       4,30 |
| Até 3 dias      |      1.834 |       3,29 |
| 4–7 dias        |      1.727 |       2,11 |
| 8–14 dias       |      1.432 |       1,67 |
| 15–30 dias      |        992 |       1,61 |
| Mais de 30 dias |        322 |       2,05 |
| **Total**       | **94.525** |          — |

Observa-se uma redução da nota média nas faixas de atraso até 15–30 dias, passando de 3,60 para atrasos de até 3 dias a 1,61 para atrasos entre 15 e 30 dias.

Na faixa de mais de 30 dias, a nota média foi de 2,05, indicando uma elevação em relação à faixa anterior. Entretanto, esse grupo possui apenas 322 pedidos, o que exige cautela na interpretação do resultado.

**H2.2 — Intensidade do desvio de entrega e distribuição das notas**

A distribuição das avaliações complementa os resultados das notas médias:

| Faixa de desvio | Pedidos | Nota 1 | Notas 4 e 5 |
| --------------- | ------: | -----: | ----------: |
| Sem atraso      |  88.221 |  6,51% |      82,81% |
| Até 3 dias      |   1.834 | 24,97% |      53,22% |
| 4–7 dias        |   1.726 | 58,52% |      22,48% |
| 8–14 dias       |   1.432 | 70,81% |      10,89% |
| 15–30 dias      |     990 | 70,91% |       8,99% |
| Mais de 30 dias |     322 | 63,66% |      22,98% |

A proporção de avaliações com nota 1 aumenta de 6,51% nos pedidos sem atraso para aproximadamente 71% nas faixas de 8–14 e 15–30 dias. Em paralelo, a participação das notas 4 e 5 diminui de 82,81% para 8,99% na faixa de 15–30 dias.

Na faixa superior a 30 dias, há uma redução da proporção de notas 1 e uma elevação da participação das notas 4 e 5 em relação à faixa anterior. Essa variação, contudo, ocorre em um grupo de menor dimensão e não permite concluir que atrasos extremos estejam associados a uma experiência mais favorável.

## Conclusão

Os resultados mostram diferenças relevantes nas avaliações dos clientes conforme o comportamento de entrega e a intensidade dos atrasos.

As entregas antecipadas e aquelas realizadas na data prevista apresentaram notas médias superiores às dos pedidos atrasados. Na análise por intensidade, observou-se uma redução progressiva da nota média e da proporção de avaliações positivas à medida que as faixas de atraso avançam até 15–30 dias, acompanhada pelo aumento da participação de notas 1.

A faixa de mais de 30 dias apresentou uma recuperação parcial das métricas de avaliação. Entretanto, o número reduzido de pedidos e as possíveis limitações de confiabilidade das datas impedem uma interpretação conclusiva desse comportamento.

É importante considerar que as avaliações dos clientes podem refletir diferentes dimensões da experiência de compra, incluindo produto, vendedor e logística. Portanto, as diferenças identificadas representam **associações descritivas**, não evidências de causalidade entre atrasos e notas.

A investigação complementa as análises anteriores do comportamento logístico ao relacionar os padrões de entrega à experiência percebida pelo cliente, mantendo a distinção entre desempenho operacional e avaliação da experiência.

## Implementação

As consultas SQL correspondentes a esta investigação estão disponíveis no arquivo:

[`experiencia_cliente.sql`](experiencia_cliente.sql)

O script contempla as três consultas principais, organizadas em duas hipóteses: comportamento de entrega e experiência do cliente; intensidade do desvio de entrega e experiência do cliente.
