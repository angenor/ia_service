-- =====================================================
-- SEED DATA FOR LLM MODELS VIA OPENROUTER
-- =====================================================

-- Ensure LLM category exists
INSERT INTO public.service_categories (slug, name, description, icon, sort_order, is_active) 
VALUES ('llm', 'Large Language Models', 'Modèles de langage avancés pour génération de texte, conversation et analyse', 'fas fa-brain', 1, true)
ON CONFLICT (slug) DO UPDATE SET 
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    icon = EXCLUDED.icon;

-- Get the LLM category ID
WITH llm_category AS (
    SELECT id FROM public.service_categories WHERE slug = 'llm'
)

-- Insert LLM models from OpenRouter
INSERT INTO public.ai_services (
    category_id,
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
    llm_category.id,
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
FROM llm_category,
(VALUES
    -- Claude Opus 4
    (
        'claude-opus-4',
        'Claude Opus 4',
        'Le modèle Claude le plus puissant, excellent pour les tâches complexes de codage et raisonnement. Peut travailler en continu pendant plusieurs heures sur des tâches complexes.',
        'anthropic',
        'https://openrouter.ai/api/v1/chat/completions',
        'fas fa-robot',
        1500, -- 15$ per 1M input tokens = 1500 points per 1M tokens
        0.015000, -- $15 per 1M input tokens
        jsonb_build_object(
            'model', 'anthropic/claude-opus-4-20250514',
            'max_tokens', 32000,
            'context_window', 200000,
            'supports_vision', true,
            'supports_functions', true,
            'pricing', jsonb_build_object(
                'input_per_million', 15.00,
                'output_per_million', 75.00
            )
        ),
        true,
        true,
        CURRENT_DATE + INTERVAL '30 days',
        jsonb_build_array(
            'Meilleur modèle pour le codage (72.5% SWE-bench)',
            'Contexte de 200K tokens',
            'Support multi-modal (texte + images)',
            'Peut travailler pendant des heures sur des tâches complexes',
            'Support des outils et fonctions'
        ),
        jsonb_build_object(
            'max_output_tokens', 32000,
            'rate_limit', '50 requêtes/minute'
        )
    ),
    
    -- Claude Sonnet 4
    (
        'claude-sonnet-4',
        'Claude Sonnet 4',
        'Équilibre parfait entre performance et efficacité. Excellent pour le codage et les tâches générales avec une meilleure contrôlabilité.',
        'anthropic',
        'https://openrouter.ai/api/v1/chat/completions',
        'fas fa-robot',
        300, -- 3$ per 1M input tokens = 300 points per 1M tokens
        0.003000, -- $3 per 1M input tokens
        jsonb_build_object(
            'model', 'anthropic/claude-sonnet-4-20250514',
            'max_tokens', 64000,
            'context_window', 200000,
            'supports_vision', true,
            'supports_functions', true,
            'pricing', jsonb_build_object(
                'input_per_million', 3.00,
                'output_per_million', 15.00
            )
        ),
        true,
        true,
        CURRENT_DATE + INTERVAL '30 days',
        jsonb_build_array(
            'Excellent pour le codage (72.7% SWE-bench)',
            'Contexte de 200K tokens',
            'Output jusqu''à 64K tokens',
            'Support multi-modal',
            'Rapport qualité/prix optimal'
        ),
        jsonb_build_object(
            'max_output_tokens', 64000,
            'rate_limit', '100 requêtes/minute'
        )
    ),
    
    -- GPT-4 Turbo
    (
        'gpt-4-turbo',
        'GPT-4 Turbo',
        'Version optimisée de GPT-4 avec des réponses plus rapides et un contexte étendu. Excellent pour les tâches complexes de raisonnement et génération.',
        'openai',
        'https://openrouter.ai/api/v1/chat/completions',
        'fas fa-microchip',
        1000, -- 10$ per 1M input tokens = 1000 points per 1M tokens
        0.010000, -- $10 per 1M input tokens
        jsonb_build_object(
            'model', 'openai/gpt-4-turbo-preview',
            'max_tokens', 4096,
            'context_window', 128000,
            'supports_vision', true,
            'supports_functions', true,
            'pricing', jsonb_build_object(
                'input_per_million', 10.00,
                'output_per_million', 30.00
            )
        ),
        true,
        false,
        NULL,
        jsonb_build_array(
            'Modèle GPT-4 optimisé pour la vitesse',
            'Contexte de 128K tokens',
            'Support multi-modal',
            'Support des outils et fonctions',
            'Excellente compréhension et génération'
        ),
        jsonb_build_object(
            'max_output_tokens', 4096,
            'rate_limit', '100 requêtes/minute'
        )
    ),
    
    -- GPT-4
    (
        'gpt-4',
        'GPT-4',
        'Le modèle phare d''OpenAI pour les tâches complexes nécessitant un raisonnement avancé et une compréhension approfondie.',
        'openai',
        'https://openrouter.ai/api/v1/chat/completions',
        'fas fa-microchip',
        3000, -- 30$ per 1M input tokens = 3000 points per 1M tokens
        0.030000, -- $30 per 1M input tokens
        jsonb_build_object(
            'model', 'openai/gpt-4',
            'max_tokens', 8192,
            'context_window', 8192,
            'supports_vision', false,
            'supports_functions', true,
            'pricing', jsonb_build_object(
                'input_per_million', 30.00,
                'output_per_million', 60.00
            )
        ),
        true,
        false,
        NULL,
        jsonb_build_array(
            'Modèle GPT-4 original',
            'Excellent raisonnement et analyse',
            'Support des outils et fonctions',
            'Haute qualité de génération',
            'Fiable pour les tâches complexes'
        ),
        jsonb_build_object(
            'max_output_tokens', 8192,
            'rate_limit', '50 requêtes/minute'
        )
    ),
    
    -- Grok
    (
        'grok',
        'Grok',
        'Modèle phare de xAI offrant des performances exceptionnelles en langage naturel, mathématiques et raisonnement.',
        'x-ai',
        'https://openrouter.ai/api/v1/chat/completions',
        'fas fa-brain',
        300, -- 3$ per 1M input tokens (base) = 300 points per 1M tokens
        0.003000, -- $3 per 1M input tokens (base)
        jsonb_build_object(
            'model', 'x-ai/grok-beta',
            'max_tokens', 131072,
            'context_window', 131072,
            'supports_vision', false,
            'supports_functions', true,
            'pricing', jsonb_build_object(
                'input_per_million', 3.00,
                'output_per_million', 15.00,
                'input_per_million_above_128k', 6.00,
                'output_per_million_above_128k', 30.00
            )
        ),
        true,
        true,
        CURRENT_DATE + INTERVAL '30 days',
        jsonb_build_array(
            'Performances exceptionnelles en raisonnement',
            'Contexte jusqu''à 131K tokens',
            'Excellent en mathématiques',
            'Prix doublé au-delà de 128K tokens',
            'Modèle phare de xAI'
        ),
        jsonb_build_object(
            'max_output_tokens', 131072,
            'rate_limit', '50 requêtes/minute',
            'pricing_note', 'Prix double pour les entrées > 128K tokens'
        )
    )
) AS models(slug, name, description, provider, api_endpoint, icon, default_cost_points, api_cost_usd, config, is_active, is_new, new_until, features, limitations)
ON CONFLICT (slug) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    provider = EXCLUDED.provider,
    api_endpoint = EXCLUDED.api_endpoint,
    icon = EXCLUDED.icon,
    default_cost_points = EXCLUDED.default_cost_points,
    api_cost_usd = EXCLUDED.api_cost_usd,
    config = EXCLUDED.config,
    is_active = EXCLUDED.is_active,
    is_new = EXCLUDED.is_new,
    new_until = EXCLUDED.new_until,
    features = EXCLUDED.features,
    limitations = EXCLUDED.limitations,
    updated_at = NOW();

-- =====================================================
-- PRICING BY COUNTRY (Optional - can be customized later)
-- =====================================================

-- Example: Set different pricing for specific countries
-- This allows you to adjust pricing based on local markets

-- Get service IDs
WITH service_ids AS (
    SELECT 
        id,
        slug,
        default_cost_points
    FROM public.ai_services 
    WHERE slug IN ('claude-opus-4', 'claude-sonnet-4', 'gpt-4-turbo', 'gpt-4', 'grok')
),
countries AS (
    -- Countries with pricing adjustments (respecting minimum price constraint)
    -- NOTE: Due to database constraint, prices cannot be lower than default_cost_points
    SELECT * FROM (VALUES 
        ('CI', 1.0), -- Côte d'Ivoire - standard pricing (constraint prevents discount)
        ('FR', 1.0), -- France - standard pricing
        ('US', 1.0), -- USA - standard pricing
        ('CA', 1.0), -- Canada - standard pricing
        ('GB', 1.0), -- UK - standard pricing
        ('DE', 1.0), -- Germany - standard pricing
        ('JP', 1.2), -- Japan - 20% premium
        ('BR', 1.0), -- Brazil - standard pricing (constraint prevents discount)
        ('IN', 1.0)  -- India - standard pricing (constraint prevents discount)
    ) AS t(country_code, price_multiplier)
)

-- Insert country-specific pricing
INSERT INTO public.service_pricing_by_country (service_id, country_code, cost_points, created_at, updated_at)
SELECT 
    s.id,
    c.country_code,
    CEIL(s.default_cost_points * c.price_multiplier)::INTEGER,
    NOW(),
    NOW()
FROM service_ids s
CROSS JOIN countries c
ON CONFLICT (service_id, country_code) DO UPDATE SET
    cost_points = EXCLUDED.cost_points,
    updated_at = NOW();

-- =====================================================
-- SERVICE AVAILABILITY BY COUNTRY
-- =====================================================

-- Make all LLM services available in all supported countries
WITH service_ids AS (
    SELECT id FROM public.ai_services 
    WHERE slug IN ('claude-opus-4', 'claude-sonnet-4', 'gpt-4-turbo', 'gpt-4', 'grok')
),
countries AS (
    SELECT unnest(ARRAY['US', 'CI', 'FR', 'CA', 'GB', 'DE', 'JP', 'BR', 'IN']) AS country_code
)

INSERT INTO public.service_availability (service_id, country_code, is_available, created_at)
SELECT 
    s.id,
    c.country_code,
    true,
    NOW()
FROM service_ids s
CROSS JOIN countries c
ON CONFLICT (service_id, country_code) DO UPDATE SET
    is_available = EXCLUDED.is_available;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Verify inserted models
SELECT 
    s.slug,
    s.name,
    s.provider,
    s.default_cost_points,
    s.api_cost_usd,
    s.config->>'model' as model_id,
    s.is_active,
    s.is_new
FROM public.ai_services s
JOIN public.service_categories c ON s.category_id = c.id
WHERE c.slug = 'llm'
ORDER BY s.default_cost_points DESC;