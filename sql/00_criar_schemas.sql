-- NEXUS
-- Criação dos Schemas
-- ============================================================
/*
Schemas do projeto:

    raw
        Dados brutos, preservados conforme a fonte.

    dw
        Modelo dimensional analítico do Nexus.

Proprietário: nexus
*/

-- 01. CRIAÇÃO DOS SCHEMAS
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS dw;

-- 02. VALIDAÇÃO
SELECT
    schema_name
FROM information_schema.schemata
WHERE schema_name IN ('raw', 'dw')
ORDER BY schema_name;
