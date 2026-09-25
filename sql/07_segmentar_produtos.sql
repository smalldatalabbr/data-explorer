-- NEXUS
-- DW
-- Enriquecimento: Segmentação de Produtos
-- ============================================================
/*
Contexto:

    A dimensão produto foi inicialmente construída mantendo a categoria original fornecida pela fonte.

    Durante a exploração dos dados, observou-se uma grande variedade de categorias, com diferentes níveis de especificidade e volume de produtos.

    Para facilitar análises agregadas, foi definida uma classificação adicional denominada SEGMENTO.

Decisão:

    A categoria original será preservada.

    O segmento funcionará como um nível analítico superior:

        segmento
            ↓
        categoria
            ↓
        produto

    A segmentação não substitui a categoria original.

    Produtos sem categoria serão classificados como:
        segmento = 'Outros'
        categoria = 'Não informado'

Observação:

    A classificação de segmento é uma classificação analítica criada para o Nexus e não representa necessariamente uma taxonomia oficial da fonte.
*/

-- 01. OVERVIEW DAS CATEGORIAS
SELECT
    COALESCE(categoria, '[SEM CATEGORIA]') AS categoria,
    COUNT(*) AS quantidade_produtos
FROM dw.dim_produto
GROUP BY categoria
ORDER BY quantidade_produtos DESC;

-- 02. ADIÇÃO DO SEGMENTO
ALTER TABLE dw.dim_produto
ADD COLUMN segmento VARCHAR(50);

-- 03. SEGMENTAÇÃO DAS CATEGORIAS
UPDATE dw.dim_produto
SET segmento = CASE

    -- Casa e Móveis
    WHEN categoria IN (
        'cama_mesa_banho',
        'moveis_decoracao',
        'moveis_escritorio',
        'moveis_sala',
        'moveis_quarto',
        'moveis_cozinha_area_de_servico_jantar_e_jardim',
        'moveis_colchao_e_estofado',
        'casa_conforto',
		'casa_conforto_2',   
		'flores',
        'la_cuisine',
		'utilidades_domesticas'
    )
    THEN 'Casa e Móveis'

    -- Construção e Ferramentas
    WHEN categoria IN (
        'construcao_ferramentas_construcao',
        'construcao_ferramentas_jardim',
        'construcao_ferramentas_seguranca',
        'construcao_ferramentas_iluminacao',
        'construcao_ferramentas_ferramentas',
        'ferramentas_jardim',
		'casa_construcao',

        'sinalizacao_e_seguranca'
    )
    THEN 'Construção e Ferramentas'

    -- Tecnologia e Eletrônicos
    WHEN categoria IN (
        'informatica_acessorios',
        'pcs',
        'pc_gamer',
        'eletronicos',
        'audio',
        'telefonia',
        'telefonia_fixa',
        'consoles_games',
        'tablets_impressao_imagem',
        'cine_foto'
    )
    THEN 'Tecnologia e Eletrônicos'

    -- Eletrodomésticos
    WHEN categoria IN (
        'eletrodomesticos',
        'eletrodomesticos_2',
        'eletroportateis',
        'climatizacao',
        'portateis_casa_forno_e_cafe',
        'portateis_cozinha_e_preparadores_de_alimentos'
    )
    THEN 'Eletrodomésticos'

    -- Moda e Acessórios
    WHEN categoria IN (
        'fashion_bolsas_e_acessorios',
        'fashion_calcados',
        'fashion_roupa_masculina',
        'fashion_roupa_feminina',
        'fashion_roupa_infanto_juvenil',
        'fashion_underwear_e_moda_praia',
        'fashion_esporte',
        'relogios_presentes',
        'malas_acessorios'
    )
    THEN 'Moda e Acessórios'

    -- Saúde e Beleza
    WHEN categoria IN (
        'bebes',
		'beleza_saude',
        'perfumaria',
        'fraldas_higiene'
    )
    THEN 'Saúde e Beleza'

    -- Esporte, Lazer e Entretenimento
    WHEN categoria IN (
        'esporte_lazer',
        'brinquedos',
        'instrumentos_musicais',
        'musica',
        'dvds_blu_ray',
        'cds_dvds_musicais',
        'artes',
        'artes_e_artesanato',
        'artigos_de_festas',
        'artigos_de_natal'
    )
    THEN 'Esporte, Lazer e Entretenimento'

    -- Livros e Papelaria
    WHEN categoria IN (
        'papelaria',
        'livros_interesse_geral',
        'livros_tecnicos',
        'livros_importados'
    )
    THEN 'Livros e Papelaria'

    -- Alimentos e Bebidas
    WHEN categoria IN (
        'alimentos',
        'alimentos_bebidas',
        'bebidas'
    )
    THEN 'Alimentos e Bebidas'
	
    -- Agro, Indústria e Negócios
    WHEN categoria IN (
        'agro_industria_e_comercio',
        'industria_comercio_e_negocios'
    )
    THEN 'Agro, Indústria e Negócios'

    -- Automotivo
    WHEN categoria = 'automotivo'
    THEN 'Automotivo'

    -- Pet
    WHEN categoria = 'pet_shop'
    THEN 'Pet'

    -- Outros / categorias sem classificação específica
    WHEN categoria IN (
        'cool_stuff',
        'market_place',
        'seguros_e_servicos'
    )
    THEN 'Outros'

END;

-- 04. TRATAMENTO DA CATEGORIA NÃO INFORMADA
-- Converte categorias nulas para uma categoria explícita
UPDATE dw.dim_produto
SET categoria = 'Não informado'
WHERE categoria IS NULL;

-- Classifica a categoria não informada no segmento Outros
UPDATE dw.dim_produto
SET segmento = 'Outros'
WHERE categoria = 'Não informado';

-- 05. VALIDAÇÃO — PRODUTOS SEM SEGMENTO
SELECT
    COUNT(*) AS produtos_sem_segmento
FROM dw.dim_produto
WHERE segmento IS NULL;

-- 06. VALIDAÇÃO — DISTRIBUIÇÃO DOS SEGMENTOS
SELECT
    segmento,
    COUNT(*) AS quantidade_produtos
FROM dw.dim_produto
GROUP BY segmento
ORDER BY quantidade_produtos DESC;

-- 07. VALIDAÇÃO — SEGMENTO × CATEGORIA
SELECT
    segmento,
    categoria,
    COUNT(*) AS quantidade_produtos
FROM dw.dim_produto
GROUP BY
    segmento,
    categoria
ORDER BY
    segmento,
    quantidade_produtos DESC;
