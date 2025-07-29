-- =====================================================
-- SEED DATA FOR LLM SUBCATEGORIES
-- =====================================================

-- Ensure LLM category exists
INSERT INTO public.service_categories (slug, name, description, icon, sort_order, is_active) 
VALUES ('llm', 'Large Language Models', 'Modèles de langage avancés pour génération de texte, conversation et analyse', 'fas fa-brain', 1, true)
ON CONFLICT (slug) DO UPDATE SET 
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    icon = EXCLUDED.icon;

-- Insert LLM subcategories
WITH llm_category AS (
    SELECT id FROM public.service_categories WHERE slug = 'llm'
)
INSERT INTO public.service_subcategories (
    category_id,
    slug,
    name,
    description,
    from_type,
    from_icon,
    to_type,
    to_icon,
    sort_order,
    is_active
)
SELECT 
    llm_category.id,
    slug,
    name,
    description,
    from_type,
    from_icon,
    to_type,
    to_icon,
    sort_order,
    is_active
FROM llm_category,
(VALUES
    -- Text to Text transformations
    (
        'chat-assistant',
        'Assistant Conversationnel',
        'Modèles optimisés pour la conversation interactive et l''assistance',
        'text',
        'fas fa-comment-dots',
        'text',
        'fas fa-comments',
        1,
        true
    ),
    (
        'text-generation',
        'Génération de Texte',
        'Création de contenu, rédaction et génération créative',
        'text',
        'fas fa-file-alt',
        'text',
        'fas fa-file-invoice',
        2,
        true
    ),
    (
        'code-generation',
        'Génération de Code',
        'Assistance au développement et génération de code',
        'text',
        'fas fa-file-alt',
        'code',
        'fas fa-code',
        3,
        true
    ),
    (
        'text-analysis',
        'Analyse de Texte',
        'Analyse, résumé et extraction d''informations',
        'text',
        'fas fa-file-alt',
        'analysis',
        'fas fa-chart-line',
        4,
        true
    ),
    (
        'translation-llm',
        'Traduction Avancée',
        'Traduction multilingue avec contexte et nuances',
        'text',
        'fas fa-language',
        'text',
        'fas fa-globe',
        5,
        true
    ),
    (
        'reasoning-math',
        'Raisonnement & Mathématiques',
        'Résolution de problèmes complexes et calculs mathématiques',
        'problem',
        'fas fa-puzzle-piece',
        'solution',
        'fas fa-lightbulb',
        6,
        true
    ),
    (
        'multimodal-llm',
        'Multimodal (Vision + Texte)',
        'Modèles capables de traiter images et texte ensemble',
        'mixed',
        'fas fa-layer-group',
        'text',
        'fas fa-comment-alt',
        7,
        true
    ),
    (
        'specialized-llm',
        'LLMs Spécialisés',
        'Modèles optimisés pour des domaines spécifiques',
        'domain',
        'fas fa-microscope',
        'expert',
        'fas fa-user-graduate',
        8,
        true
    )
) AS subcategories(slug, name, description, from_type, from_icon, to_type, to_icon, sort_order, is_active)
ON CONFLICT (slug) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    from_type = EXCLUDED.from_type,
    from_icon = EXCLUDED.from_icon,
    to_type = EXCLUDED.to_type,
    to_icon = EXCLUDED.to_icon,
    sort_order = EXCLUDED.sort_order,
    is_active = EXCLUDED.is_active;

-- =====================================================
-- UPDATE LLM MODELS WITH SUBCATEGORIES
-- =====================================================

-- Get subcategory IDs
WITH subcategory_mapping AS (
    SELECT 
        slug,
        id
    FROM public.service_subcategories
    WHERE category_id = (SELECT id FROM public.service_categories WHERE slug = 'llm')
)
-- Update existing LLM models to assign appropriate subcategories
UPDATE public.ai_services AS s
SET 
    subcategory_id = sm.id,
    category_id = NULL, -- Remove direct category assignment when using subcategory
    updated_at = NOW()
FROM (
    VALUES 
        -- Claude models are excellent for chat, code, and reasoning
        ('claude-opus-4', 'chat-assistant'),
        ('claude-sonnet-4', 'chat-assistant'),
        -- GPT models are versatile, primarily chat-focused
        ('gpt-4-turbo', 'chat-assistant'),
        ('gpt-4', 'chat-assistant'),
        -- Grok excels at reasoning and math
        ('grok', 'reasoning-math')
) AS model_mapping(model_slug, subcategory_slug)
JOIN subcategory_mapping sm ON sm.slug = model_mapping.subcategory_slug
WHERE s.slug = model_mapping.model_slug;

-- =====================================================
-- CREATE ADDITIONAL MODEL ENTRIES FOR OTHER SUBCATEGORIES
-- =====================================================

-- Insert same models but for different use cases (different subcategories)
WITH subcategories AS (
    SELECT id, slug FROM public.service_subcategories
    WHERE category_id = (SELECT id FROM public.service_categories WHERE slug = 'llm')
)
INSERT INTO public.ai_services (
    subcategory_id,
    slug,
    name,
    description,
    provider,
    api_endpoint,
    icon,
    default_cost_points,
    api_cost_usd,
    config,
    is_active,
    is_new,
    new_until,
    features,
    limitations
)
SELECT 
    sc.id,
    CONCAT(base_model.slug, '-', sc.slug),
    CONCAT(base_model.name, ' (', 
        CASE sc.slug
            WHEN 'code-generation' THEN 'Code'
            WHEN 'text-generation' THEN 'Contenu'
            WHEN 'text-analysis' THEN 'Analyse'
            WHEN 'translation-llm' THEN 'Traduction'
            WHEN 'multimodal-llm' THEN 'Vision'
            ELSE 'Spécialisé'
        END, ')'),
    CASE sc.slug
        WHEN 'code-generation' THEN CONCAT(base_model.description, ' - Optimisé pour la génération et l''analyse de code.')
        WHEN 'text-generation' THEN CONCAT(base_model.description, ' - Optimisé pour la création de contenu et rédaction.')
        WHEN 'text-analysis' THEN CONCAT(base_model.description, ' - Optimisé pour l''analyse et le résumé de texte.')
        WHEN 'translation-llm' THEN CONCAT(base_model.description, ' - Optimisé pour la traduction multilingue.')
        WHEN 'multimodal-llm' THEN CONCAT(base_model.description, ' - Capacités multimodales (texte + images).')
        ELSE base_model.description
    END,
    base_model.provider,
    base_model.api_endpoint,
    base_model.icon,
    base_model.default_cost_points,
    base_model.api_cost_usd,
    base_model.config,
    base_model.is_active,
    false, -- not new for variants
    NULL,
    base_model.features,
    base_model.limitations
FROM subcategories sc
CROSS JOIN LATERAL (
    SELECT * FROM public.ai_services 
    WHERE slug IN ('claude-opus-4', 'claude-sonnet-4', 'gpt-4-turbo')
    AND subcategory_id IS NOT NULL
) AS base_model
WHERE sc.slug IN ('code-generation', 'text-generation', 'text-analysis')
AND NOT EXISTS (
    SELECT 1 FROM public.ai_services 
    WHERE slug = CONCAT(base_model.slug, '-', sc.slug)
)
ON CONFLICT (slug) DO NOTHING;

-- Special case: Add multimodal versions only for models that support vision
INSERT INTO public.ai_services (
    subcategory_id,
    slug,
    name,
    description,
    provider,
    api_endpoint,
    icon,
    default_cost_points,
    api_cost_usd,
    config,
    is_active,
    is_new,
    new_until,
    features,
    limitations
)
SELECT 
    (SELECT id FROM public.service_subcategories WHERE slug = 'multimodal-llm'),
    CONCAT(base_model.slug, '-vision'),
    CONCAT(base_model.name, ' (Vision)'),
    CONCAT(base_model.description, ' - Mode multimodal avec analyse d''images activée.'),
    base_model.provider,
    base_model.api_endpoint,
    'fas fa-eye',
    CEIL(base_model.default_cost_points * 1.2)::INTEGER, -- 20% more expensive for vision
    base_model.api_cost_usd * 1.2,
    jsonb_set(base_model.config, '{vision_enabled}', 'true'::jsonb),
    base_model.is_active,
    true,
    CURRENT_DATE + INTERVAL '30 days',
    base_model.features || jsonb_build_array('Analyse d''images haute résolution', 'Description détaillée d''images', 'OCR intégré'),
    base_model.limitations
FROM public.ai_services AS base_model
WHERE base_model.slug IN ('claude-opus-4', 'claude-sonnet-4', 'gpt-4-turbo')
AND (base_model.config->>'supports_vision')::boolean = true
AND NOT EXISTS (
    SELECT 1 FROM public.ai_services 
    WHERE slug = CONCAT(base_model.slug, '-vision')
)
ON CONFLICT (slug) DO NOTHING;

-- =====================================================
-- PRICING AND AVAILABILITY FOR NEW MODEL VARIANTS
-- =====================================================

-- Copy pricing from base models to their variants
WITH base_pricing AS (
    SELECT 
        spc.country_code,
        spc.cost_points,
        s.slug as base_slug
    FROM public.service_pricing_by_country spc
    JOIN public.ai_services s ON s.id = spc.service_id
    WHERE s.slug IN ('claude-opus-4', 'claude-sonnet-4', 'gpt-4-turbo')
),
variant_models AS (
    SELECT id, slug
    FROM public.ai_services
    WHERE slug LIKE '%-%-%' -- Pattern for variant models
    AND slug NOT IN ('claude-opus-4', 'claude-sonnet-4', 'gpt-4-turbo', 'gpt-4', 'grok')
)
INSERT INTO public.service_pricing_by_country (service_id, country_code, cost_points, created_at, updated_at)
SELECT 
    vm.id,
    bp.country_code,
    CASE 
        WHEN vm.slug LIKE '%-vision' THEN CEIL(bp.cost_points * 1.2)::INTEGER
        ELSE bp.cost_points
    END,
    NOW(),
    NOW()
FROM variant_models vm
JOIN base_pricing bp ON vm.slug LIKE bp.base_slug || '-%'
ON CONFLICT (service_id, country_code) DO NOTHING;

-- Copy availability from base models to their variants
WITH base_availability AS (
    SELECT 
        sa.country_code,
        sa.is_available,
        s.slug as base_slug
    FROM public.service_availability sa
    JOIN public.ai_services s ON s.id = sa.service_id
    WHERE s.slug IN ('claude-opus-4', 'claude-sonnet-4', 'gpt-4-turbo')
),
variant_models AS (
    SELECT id, slug
    FROM public.ai_services
    WHERE slug LIKE '%-%-%'
    AND slug NOT IN ('claude-opus-4', 'claude-sonnet-4', 'gpt-4-turbo', 'gpt-4', 'grok')
)
INSERT INTO public.service_availability (service_id, country_code, is_available, created_at)
SELECT 
    vm.id,
    ba.country_code,
    ba.is_available,
    NOW()
FROM variant_models vm
JOIN base_availability ba ON vm.slug LIKE ba.base_slug || '-%'
ON CONFLICT (service_id, country_code) DO NOTHING;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Show all LLM subcategories
SELECT 
    sc.slug,
    sc.name,
    sc.from_type || ' → ' || sc.to_type as transformation,
    COUNT(s.id) as model_count
FROM public.service_subcategories sc
LEFT JOIN public.ai_services s ON s.subcategory_id = sc.id
WHERE sc.category_id = (SELECT id FROM public.service_categories WHERE slug = 'llm')
GROUP BY sc.id, sc.slug, sc.name, sc.from_type, sc.to_type
ORDER BY sc.sort_order;

-- Show all LLM models with their subcategories
SELECT 
    s.slug,
    s.name,
    sc.name as subcategory,
    s.provider,
    s.default_cost_points,
    s.is_active
FROM public.ai_services s
JOIN public.service_subcategories sc ON s.subcategory_id = sc.id
WHERE sc.category_id = (SELECT id FROM public.service_categories WHERE slug = 'llm')
ORDER BY sc.sort_order, s.default_cost_points DESC;