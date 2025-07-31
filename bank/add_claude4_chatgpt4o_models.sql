-- =====================================================
-- Ajout des modèles Claude 4 et ChatGPT 4o
-- =====================================================

-- Récupérer l'ID de la catégorie LLM
DO $$
DECLARE
    v_llm_category_id UUID;
    v_chat_ability_id UUID;
    v_code_ability_id UUID;
    v_creative_ability_id UUID;
    v_reasoning_ability_id UUID;
    v_vision_ability_id UUID;
BEGIN
    -- Récupérer l'ID de la catégorie LLM
    SELECT id INTO v_llm_category_id
    FROM public.service_categories
    WHERE slug = 'llm';

    -- Récupérer les IDs des abilities existantes
    SELECT id INTO v_chat_ability_id
    FROM public.service_abilities
    WHERE slug = 'chat-conversation';

    SELECT id INTO v_code_ability_id
    FROM public.service_abilities
    WHERE slug = 'code-generation';

    SELECT id INTO v_creative_ability_id
    FROM public.service_abilities
    WHERE slug = 'creative-writing';

    SELECT id INTO v_reasoning_ability_id
    FROM public.service_abilities
    WHERE slug = 'advanced-reasoning';

    SELECT id INTO v_vision_ability_id
    FROM public.service_abilities
    WHERE slug = 'vision-analysis';

    -- =====================================================
    -- CLAUDE 4 MODELS
    -- =====================================================

    -- Claude Sonnet 4
    INSERT INTO public.ai_services (
        category_id,
        slug,
        name,
        description,
        provider,
        api_endpoint,
        default_cost_points,
        api_cost_usd,
        config,
        is_active,
        is_new,
        new_until,
        features,
        limitations
    ) VALUES (
        v_llm_category_id,
        'claude-sonnet-4',
        'Claude 4 Sonnet',
        'Modèle Claude de nouvelle génération avec capacités améliorées en codage et raisonnement',
        'anthropic',
        'anthropic/claude-sonnet-4',
        30,
        0.003,
        '{"model": "anthropic/claude-sonnet-4", "max_tokens": 64000, "temperature": 1}'::jsonb,
        true,
        true,
        CURRENT_DATE + INTERVAL '30 days',
        '["Codage avancé", "Raisonnement précis", "Multimodal", "200k tokens de contexte", "Contrôlabilité améliorée"]'::jsonb,
        '{"rate_limit": "50 req/min", "max_output": "64000 tokens", "image_support": true}'::jsonb
    ) ON CONFLICT (slug) DO UPDATE SET
        name = EXCLUDED.name,
        description = EXCLUDED.description,
        api_endpoint = EXCLUDED.api_endpoint,
        default_cost_points = EXCLUDED.default_cost_points,
        api_cost_usd = EXCLUDED.api_cost_usd,
        config = EXCLUDED.config,
        is_new = EXCLUDED.is_new,
        new_until = EXCLUDED.new_until,
        features = EXCLUDED.features,
        limitations = EXCLUDED.limitations,
        updated_at = NOW();

    -- Ajouter les abilities pour Claude Sonnet 4
    INSERT INTO public.service_model_abilities (service_id, ability_id, cost_multiplier, is_active)
    SELECT 
        (SELECT id FROM public.ai_services WHERE slug = 'claude-sonnet-4'),
        unnest(ARRAY[v_chat_ability_id, v_code_ability_id, v_creative_ability_id, v_reasoning_ability_id, v_vision_ability_id]),
        1.0,
        true
    ON CONFLICT (service_id, ability_id) DO UPDATE SET
        cost_multiplier = EXCLUDED.cost_multiplier,
        is_active = EXCLUDED.is_active;

    -- Claude Opus 4
    INSERT INTO public.ai_services (
        category_id,
        slug,
        name,
        description,
        provider,
        api_endpoint,
        default_cost_points,
        api_cost_usd,
        config,
        is_active,
        is_new,
        new_until,
        features,
        limitations
    ) VALUES (
        v_llm_category_id,
        'claude-opus-4',
        'Claude 4 Opus',
        'Le meilleur modèle de codage au monde avec capacités étendues pour les workflows agentiques',
        'anthropic',
        'anthropic/claude-opus-4',
        150,
        0.015,
        '{"model": "anthropic/claude-opus-4", "max_tokens": 32000, "temperature": 1}'::jsonb,
        true,
        true,
        CURRENT_DATE + INTERVAL '30 days',
        '["Meilleur modèle de codage", "Workflows agentiques", "SWE-bench 72.5%", "Terminal-bench 43.2%", "200k tokens de contexte"]'::jsonb,
        '{"rate_limit": "10 req/min", "max_output": "32000 tokens", "image_support": true, "moderation_required": true}'::jsonb
    ) ON CONFLICT (slug) DO UPDATE SET
        name = EXCLUDED.name,
        description = EXCLUDED.description,
        api_endpoint = EXCLUDED.api_endpoint,
        default_cost_points = EXCLUDED.default_cost_points,
        api_cost_usd = EXCLUDED.api_cost_usd,
        config = EXCLUDED.config,
        is_new = EXCLUDED.is_new,
        new_until = EXCLUDED.new_until,
        features = EXCLUDED.features,
        limitations = EXCLUDED.limitations,
        updated_at = NOW();

    -- Ajouter les abilities pour Claude Opus 4
    INSERT INTO public.service_model_abilities (service_id, ability_id, cost_multiplier, is_active)
    SELECT 
        (SELECT id FROM public.ai_services WHERE slug = 'claude-opus-4'),
        unnest(ARRAY[v_chat_ability_id, v_code_ability_id, v_creative_ability_id, v_reasoning_ability_id, v_vision_ability_id]),
        1.0,
        true
    ON CONFLICT (service_id, ability_id) DO UPDATE SET
        cost_multiplier = EXCLUDED.cost_multiplier,
        is_active = EXCLUDED.is_active;

    -- =====================================================
    -- OPENAI MODELS
    -- =====================================================

    -- ChatGPT 4o Latest
    INSERT INTO public.ai_services (
        category_id,
        slug,
        name,
        description,
        provider,
        api_endpoint,
        default_cost_points,
        api_cost_usd,
        config,
        is_active,
        is_new,
        new_until,
        features,
        limitations
    ) VALUES (
        v_llm_category_id,
        'chatgpt-4o-latest',
        'ChatGPT 4o Latest',
        'Version la plus récente de ChatGPT 4o avec améliorations RLHF continues',
        'openai',
        'openai/chatgpt-4o-latest',
        50,
        0.005,
        '{"model": "openai/chatgpt-4o-latest", "max_tokens": 4096, "temperature": 1}'::jsonb,
        true,
        true,
        CURRENT_DATE + INTERVAL '30 days',
        '["Continuellement mis à jour", "RLHF avancé", "Multimodal", "128k tokens de contexte"]'::jsonb,
        '{"rate_limit": "30 req/min", "max_output": "4096 tokens", "image_support": true, "production_warning": "Non adapté pour production"}'::jsonb
    ) ON CONFLICT (slug) DO UPDATE SET
        name = EXCLUDED.name,
        description = EXCLUDED.description,
        api_endpoint = EXCLUDED.api_endpoint,
        default_cost_points = EXCLUDED.default_cost_points,
        api_cost_usd = EXCLUDED.api_cost_usd,
        config = EXCLUDED.config,
        is_new = EXCLUDED.is_new,
        new_until = EXCLUDED.new_until,
        features = EXCLUDED.features,
        limitations = EXCLUDED.limitations,
        updated_at = NOW();

    -- Ajouter les abilities pour ChatGPT 4o Latest
    INSERT INTO public.service_model_abilities (service_id, ability_id, cost_multiplier, is_active)
    SELECT 
        (SELECT id FROM public.ai_services WHERE slug = 'chatgpt-4o-latest'),
        unnest(ARRAY[v_chat_ability_id, v_code_ability_id, v_creative_ability_id, v_reasoning_ability_id, v_vision_ability_id]),
        1.0,
        true
    ON CONFLICT (service_id, ability_id) DO UPDATE SET
        cost_multiplier = EXCLUDED.cost_multiplier,
        is_active = EXCLUDED.is_active;

END $$;

-- Vérification des insertions
SELECT 
    s.name as model_name,
    s.provider,
    s.default_cost_points,
    s.api_cost_usd,
    s.is_active,
    s.is_new,
    COUNT(sma.ability_id) as abilities_count
FROM public.ai_services s
LEFT JOIN public.service_model_abilities sma ON s.id = sma.service_id
WHERE s.slug IN (
    'claude-sonnet-4',
    'claude-opus-4',
    'chatgpt-4o-latest'
)
GROUP BY s.name, s.provider, s.default_cost_points, s.api_cost_usd, s.is_active, s.is_new
ORDER BY s.provider, s.default_cost_points DESC;