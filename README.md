# Data Explorer

### *Da origem dos dados à construção de uma base analítica confiável.*

![Author](https://img.shields.io/badge/author-Jhonathan%20Domingues-lightgrey)
![License](https://img.shields.io/badge/license-MIT-blue)
![Status](https://img.shields.io/badge/status-Em%20andamento-yellow)

![Python](https://img.shields.io/badge/language-Python-3776AB?logo=python&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/database-PostgreSQL-4169E1?logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/query-SQL-blue?logo=postgresql&logoColor=white)
![Docker](https://img.shields.io/badge/environment-Docker-2496ED?logo=docker&logoColor=white)
![uv](https://img.shields.io/badge/package%20manager-uv-6B4FBB)

O **Data Explorer** é um case de Analytics desenvolvido no ecossistema **Nexus**, com foco na transformação de dados operacionais brutos em uma base analítica estruturada, validada e reproduzível.

Nesta primeira etapa, o projeto concentra-se na ingestão, tratamento, modelagem dimensional e validação dos dados, disponibilizando uma camada analítica em PostgreSQL pronta para exploração e investigação.

> **Dados de origem → RAW → Data Warehouse → Validação → Base analítica**

---

## 1. O que foi construído

A primeira fase do Data Explorer estabelece a fundação de dados utilizada nas etapas analíticas posteriores.

O processo contempla:

- preservação dos dados de origem;
- ingestão automatizada no PostgreSQL;
- tratamento e transformação;
- modelagem dimensional;
- construção das tabelas analíticas;
- validação da carga e das estruturas;
- ambiente reproduzível utilizando Docker.

A arquitetura foi mantida proporcional ao objetivo do projeto, priorizando **clareza, rastreabilidade e reprodutibilidade**.

---

## 2. Arquitetura

```text
Dados de origem
      ↓
   Ingestão
      ↓
     RAW
      ↓
Tratamento e transformação
      ↓
Data Warehouse
      ↓
   Validação
      ↓
Base analítica
````

O PostgreSQL é executado em um container Docker.

A camada `RAW` preserva os dados de origem, enquanto o schema `dw` organiza os dados em uma estrutura dimensional orientada ao consumo analítico.

---

## 3. Pipeline

### Ingestão

A ingestão é realizada em Python utilizando `psycopg` e `COPY` do PostgreSQL.

Os dados são carregados inicialmente na camada `RAW`, preservando sua estrutura de origem antes das transformações.

### Modelagem

A partir da camada `RAW`, scripts SQL versionados constroem o Data Warehouse dimensional.

Entre as estruturas estão:

* dimensão de clientes;
* dimensão de produtos;
* dimensão de vendedores;
* fato de pedidos;
* fato de itens dos pedidos;
* fato de avaliações;
* segmentação de produtos;
* informações derivadas dos pedidos.

### Validação

Após a construção do Data Warehouse, um conjunto de validações verifica a consistência da estrutura e dos principais resultados da carga.

Entre os controles estão verificações relacionadas a duplicidades, períodos de dados e consistência das estruturas construídas.

---

## 4. Estrutura do projeto

```text
data_explorer/
├── data/
│   └── olist.zip
│
├── scripts/
│   └── ingest_raw.py
│
├── sql/
│   ├── 00_criar_schemas.sql
│   ├── 01_criar_dim_cliente.sql
│   ├── 02_criar_dim_produto.sql
│   ├── 03_criar_dim_vendedor.sql
│   ├── 04_criar_fato_pedido.sql
│   ├── 05_criar_fato_review.sql
│   ├── 06_criar_fato_item_pedido.sql
│   ├── 07_segmentar_produtos.sql
│   ├── 08_enriquecer_fato_pedido.sql
│   └── 09_validar_dw.sql
│
├── docker-compose.yml
├── pyproject.toml
├── uv.lock
├── setup.sh
└── README.md
```

### Componentes principais

| Componente           | Responsabilidade                                          |
| -------------------- | --------------------------------------------------------- |
| `data/`              | Dados de origem versionados utilizados pelo pipeline      |
| `scripts/`           | Automação da ingestão                                     |
| `sql/`               | Construção, transformação e validação da camada analítica |
| `docker-compose.yml` | Ambiente PostgreSQL                                       |
| `setup.sh`           | Automação completa da construção do ambiente              |
| `pyproject.toml`     | Configuração e dependências Python                        |
| `uv.lock`            | Controle das versões das dependências                     |

---

## 5. Reprodução

O projeto foi estruturado para que a infraestrutura analítica possa ser reconstruída do zero a partir do repositório.

### Pré-requisitos

* Git
* Docker
* Python 3.12+
* uv

### Variáveis de ambiente

Crie um arquivo `.env` na raiz do repositório com as credenciais utilizadas pelo PostgreSQL:

```env
POSTGRES_DB=nexus
POSTGRES_USER=nexus
POSTGRES_PASSWORD=SUA_SENHA
```

> Substitua `SUA_SENHA` pela senha desejada para o ambiente local.

### Execução

```bash
git clone https://github.com/smalldatalabbr/data-explorer.git
cd data-explorer
./setup.sh
```

O `setup.sh` automatiza todo o processo:

1. inicia o PostgreSQL via Docker Compose;
2. cria os schemas;
3. executa a ingestão dos dados;
4. constrói o Data Warehouse;
5. executa as validações finais.

Ao término, o ambiente estará disponível em:

```text
Host:     localhost
Port:     5432
Database: nexus
User:     nexus
```

O ambiente pode ser reconstruído a partir do zero utilizando o mesmo procedimento.

---

## 6. Estado desta versão

Esta versão concentra-se na **fundação técnica e na camada de dados do Data Explorer**.

Ao final da etapa, o projeto possui:

* dados de origem preservados;
* camada `RAW` carregada;
* Data Warehouse dimensional;
* scripts SQL versionados;
* ingestão automatizada;
* ambiente PostgreSQL reproduzível;
* validações automatizadas.

A próxima etapa incorporará a camada de **exploração analítica, investigação e visualização**, utilizando a base construída nesta fase.

---

## Disclaimer

> Este projeto foi desenvolvido para fins educacionais e de demonstração de capacidade técnica. As análises e visualizações apresentadas têm caráter exploratório e ilustrativo e não devem ser utilizadas diretamente como base para decisões operacionais ou aplicações em ambiente produtivo.

---

## Tecnologias

* **Python** — ingestão e automação
* **PostgreSQL** — armazenamento e camada analítica
* **SQL** — transformação, modelagem e validação
* **Docker** — ambiente reproduzível
* **uv** — gerenciamento do ambiente Python

---

## Licença

Este repositório é licenciado sob a **MIT License**.