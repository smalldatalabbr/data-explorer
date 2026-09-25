#!/usr/bin/env bash

set -e

# ============================================================
# NEXUS DATA EXPLORER
# Setup do ambiente de dados
# ============================================================

echo "=========================================="
echo " NEXUS DATA EXPLORER"
echo " Configuração do ambiente"
echo "=========================================="
echo


# ============================================================
# 01. VERIFICAÇÃO DE PRÉ-REQUISITOS
# ============================================================

echo "→ Verificando pré-requisitos..."

if ! command -v docker >/dev/null 2>&1; then
    echo "✗ Docker não encontrado."
    echo "  Instale o Docker antes de continuar."
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "✗ Docker encontrado, mas não está acessível."
    echo "  Verifique se o Docker está em execução e se seu usuário"
    echo "  possui permissão para acessar o Docker."
    exit 1
fi

if ! command -v uv >/dev/null 2>&1; then
    echo "✗ uv não encontrado."
    echo "  Instale o uv antes de continuar."
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "✗ Python não encontrado."
    echo "  O projeto requer Python 3.12 ou superior."
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')

if ! python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 12) else 1)'; then
    echo "✗ Python $PYTHON_VERSION encontrado."
    echo "  O projeto requer Python 3.12 ou superior."
    exit 1
fi

echo "   ✓ Docker"
echo "   ✓ uv"
echo "   ✓ Python $PYTHON_VERSION"
echo


# ============================================================
# 02. AMBIENTE PYTHON
# ============================================================

echo "→ Sincronizando ambiente Python..."

uv sync

echo "   ✓ Ambiente Python pronto."
echo


# ============================================================
# 03. POSTGRESQL
# ============================================================

echo "→ Iniciando PostgreSQL..."

docker compose up -d

echo "   ✓ Container PostgreSQL iniciado."
echo


# ============================================================
# 04. AGUARDAR POSTGRESQL
# ============================================================

echo "→ Aguardando PostgreSQL ficar disponível..."

until docker exec nexus-postgres pg_isready -U nexus -d nexus >/dev/null 2>&1
do
    sleep 1
done

echo "   ✓ PostgreSQL disponível."
echo


# ============================================================
# 05. CRIAÇÃO DOS SCHEMAS
# ============================================================

echo "→ Criando schemas..."

docker exec -i nexus-postgres \
    psql -U nexus -d nexus \
    < sql/00_criar_schemas.sql

echo "   ✓ Schemas criados."
echo


# ============================================================
# 06. INGESTÃO RAW
# ============================================================

echo "→ Executando ingestão RAW..."

uv run python scripts/ingest_raw.py

echo "   ✓ RAW carregado."
echo


# ============================================================
# 07. CONSTRUÇÃO DO DW
# ============================================================

echo "→ Construindo Data Warehouse..."

for file in \
    sql/01_criar_dim_cliente.sql \
    sql/02_criar_dim_produto.sql \
    sql/03_criar_dim_vendedor.sql \
    sql/04_criar_fato_pedido.sql \
    sql/05_criar_fato_review.sql \
    sql/06_criar_fato_item_pedido.sql \
    sql/07_segmentar_produtos.sql \
    sql/08_enriquecer_fato_pedido.sql
do
    echo "   → Executando $(basename "$file")"

    docker exec -i nexus-postgres \
        psql -U nexus -d nexus \
        < "$file"
done

echo "   ✓ Data Warehouse construído."
echo


# ============================================================
# 08. VALIDAÇÃO
# ============================================================

echo "→ Validando Data Warehouse..."

docker exec -i nexus-postgres \
    psql -U nexus -d nexus \
    < sql/09_validar_dw.sql

echo


# ============================================================
# FINALIZAÇÃO
# ============================================================

echo "=========================================="
echo " ✓ NEXUS DATA EXPLORER CONFIGURADO"
echo "=========================================="
echo
echo "PostgreSQL : localhost:5432"
echo "Database   : nexus"
echo "User       : nexus"
echo
echo "O ambiente está pronto."