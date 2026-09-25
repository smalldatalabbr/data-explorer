"""
Ingestão do dataset OLIST:
ZIP → PostgreSQL RAW

Fonte:
    data/raw/olist.zip

Destino:
    PostgreSQL
    database: nexus
    schema: raw

Responsabilidade:
    Preservar os dados da fonte no PostgreSQL, mantendo a estrutura original das colunas.

Observação:
    Todas as colunas são carregadas como TEXT.
    Tipagem, tratamento e modelagem analítica serão realizados posteriormente no DW.
"""
import csv
import os
import shutil
from pathlib import Path
from zipfile import ZipFile

import psycopg
from dotenv import load_dotenv


load_dotenv()

# CONFIGURAÇÃO

BASE_DIR = Path(__file__).resolve().parents[1]

DATA_DIR = BASE_DIR / "data"
RAW_DATA = DATA_DIR / "olist.zip"
TMP_EXTRACT = DATA_DIR / "_tmp_extract"

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": os.getenv("POSTGRES_DB"),
    "user": os.getenv("POSTGRES_USER"),
    "password": os.getenv("POSTGRES_PASSWORD"),
}

SCHEMA_NAME = "raw"


# MAPEAMENTO DOS ARQUIVOS

TABLE_MAP = {
    "olist_customers_dataset.csv": "customers",
    "olist_geolocation_dataset.csv": "geolocation",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_orders_dataset.csv": "orders",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "product_category_name_translation.csv": "category_translation",
}


# FUNÇÕES AUXILIARES

def clean_temp_folder():
    """Remove a pasta temporária de extração, se existir."""

    if TMP_EXTRACT.exists():
        shutil.rmtree(TMP_EXTRACT)

    TMP_EXTRACT.mkdir(parents=True, exist_ok=True)


def extract_zip():
    """Extrai o ZIP para uma pasta temporária."""

    with ZipFile(RAW_DATA, "r") as zf:
        zf.extractall(TMP_EXTRACT)


def find_csv_files():
    """Localiza os CSVs extraídos."""

    return {
        path.name: path
        for path in TMP_EXTRACT.rglob("*.csv")
    }


def quote_identifier(identifier):
    """Protege identificadores SQL."""

    return '"' + identifier.replace('"', '""') + '"'


def infer_columns(csv_path):
    """
    Lê o cabeçalho do CSV para criar a tabela RAW.
    """

    with open(csv_path, "r", encoding="utf-8-sig", newline="") as f:
        reader = csv.reader(f)
        columns = next(reader)

    return columns


def create_raw_table(cur, table_name, columns):
    """
    Cria a tabela RAW com todas as colunas como TEXT.

    A RAW deve preservar a representação da fonte.
    Tipagem, tratamento e modelagem ficam para o DW.
    """

    quoted_columns = ", ".join(
        f"{quote_identifier(column)} TEXT"
        for column in columns
    )

    sql = f"""
        DROP TABLE IF EXISTS {SCHEMA_NAME}.{quote_identifier(table_name)};

        CREATE TABLE {SCHEMA_NAME}.{quote_identifier(table_name)} (
            {quoted_columns}
        );
    """

    cur.execute(sql)


def load_csv(cur, table_name, csv_path, columns):
    """
    Carrega o CSV diretamente para a tabela RAW.
    """

    column_list = ", ".join(
        quote_identifier(column)
        for column in columns
    )

    sql = f"""
        COPY {SCHEMA_NAME}.{quote_identifier(table_name)}
        ({column_list})
        FROM STDIN
        WITH (
            FORMAT CSV,
            HEADER TRUE,
            DELIMITER ',',
            QUOTE '"',
            ESCAPE '"'
        );
    """

    with cur.copy(sql) as copy:
        with open(csv_path, "rb") as f:
            while data := f.read(1024 * 1024):
                copy.write(data)


def count_rows(cur, table_name):
    """Retorna a quantidade de registros carregados."""

    cur.execute(
        f"""
        SELECT COUNT(*)
        FROM {SCHEMA_NAME}.{quote_identifier(table_name)}
        """
    )

    return cur.fetchone()[0]


# MAIN

def main():

    if not RAW_DATA.exists():
        raise FileNotFoundError(
            f"Dataset não encontrado: {RAW_DATA}"
        )

    clean_temp_folder()

    try:

        print("→ Extraindo dataset...")
        extract_zip()

        csv_files = find_csv_files()

        if not csv_files:
            raise RuntimeError(
                "Nenhum arquivo CSV encontrado no ZIP."
            )

        expected_files = set(TABLE_MAP.keys())
        found_files = set(csv_files.keys())

        missing_files = expected_files - found_files

        if missing_files:
            raise RuntimeError(
                f"Arquivos esperados não encontrados: "
                f"{sorted(missing_files)}"
            )

        print(f"→ {len(csv_files)} CSVs encontrados.")

        with psycopg.connect(**DB_CONFIG) as conn:

            with conn.cursor() as cur:

                for filename, table_name in TABLE_MAP.items():

                    csv_path = csv_files[filename]

                    print(
                        f"→ Carregando {filename} "
                        f"→ {SCHEMA_NAME}.{table_name}"
                    )

                    columns = infer_columns(csv_path)

                    create_raw_table(
                        cur,
                        table_name,
                        columns
                    )

                    load_csv(
                        cur,
                        table_name,
                        csv_path,
                        columns
                    )

                    rows = count_rows(
                        cur,
                        table_name
                    )

                    print(
                        f"   ✓ {SCHEMA_NAME}.{table_name}: "
                        f"{rows:,} registros"
                    )

            conn.commit()

        print("\n✔ RAW carregado com sucesso.")

    finally:

        if TMP_EXTRACT.exists():
            shutil.rmtree(TMP_EXTRACT)

        print("→ Arquivos temporários removidos.")


if __name__ == "__main__":
    main()