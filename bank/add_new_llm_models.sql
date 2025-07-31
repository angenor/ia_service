-- =====================================================
-- Ajout des nouveaux modèles LLM
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

    -- Créer les abilities pour LLM si elles n'existent pas
    -- Chat conversationnel
    INSERT INTO public.service_abilities (category_id, slug, name, description, from_type, to_type, sort_order)
    VALUES (v_llm_category_id, 'chat-conversation', 'Chat Conversationnel', 'Conversation en langage naturel', 'text', 'text', 1)
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_chat_ability_id;

    -- Génération de code
    INSERT INTO public.service_abilities (category_id, slug, name, description, from_type, to_type, sort_order)
    VALUES (v_llm_category_id, 'code-generation', 'Génération de Code', 'Écriture et modification de code', 'text', 'code', 2)
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_code_ability_id;

    -- Écriture créative
    INSERT INTO public.service_abilities (category_id, slug, name, description, from_type, to_type, sort_order)
    VALUES (v_llm_category_id, 'creative-writing', 'Écriture Créative', 'Rédaction créative et storytelling', 'text', 'text', 3)
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_creative_ability_id;

    -- Raisonnement avancé
    INSERT INTO public.service_abilities (category_id, slug, name, description, from_type, to_type, sort_order)
    VALUES (v_llm_category_id, 'advanced-reasoning', 'Raisonnement Avancé', 'Analyse complexe et résolution de problèmes', 'text', 'text', 4)
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_reasoning_ability_id;

    -- Analyse d'images
    INSERT INTO public.service_abilities (category_id, slug, name, description, from_type, to_type, sort_order)
    VALUES (v_llm_category_id, 'vision-analysis', 'Analyse d''Images', 'Compréhension et analyse d''images', 'image', 'text', 5)
    ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name
    RETURNING id INTO v_vision_ability_id;

    -- =====================================================
    -- GEMINI MODELS
    -- =====================================================

    -- Gemini 2.5 Flash
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
        'gemini-2.5-flash',
        'Gemini 2.5 Flash',
        'Modèle ultra-rapide et économique pour les tâches simples à moyennes',
        'google',
        'google/gemini-2.5-flash',
        5,
        0.0005,
        '{"model": "google/gemini-2.5-flash", "max_tokens": 1048500, "temperature": 1}'::jsonb,
        true,
        true,
        CURRENT_DATE + INTERVAL '30 days',
        '["Ultra rapide", "Économique", "Multimodal", "1M tokens de contexte"]'::jsonb,
        '{"rate_limit": "100 req/min", "max_output": "8192 tokens"}'::jsonb
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

    -- Ajouter les abilities pour Gemini 2.5 Flash
    INSERT INTO public.service_model_abilities (service_id, ability_id, cost_multiplier, is_active)
    SELECT 
        (SELECT id FROM public.ai_services WHERE slug = 'gemini-2.5-flash'),
        unnest(ARRAY[v_chat_ability_id, v_code_ability_id, v_creative_ability_id, v_vision_ability_id]),
        1.0,
        true
    ON CONFLICT (service_id, ability_id) DO UPDATE SET
        cost_multiplier = EXCLUDED.cost_multiplier,
        is_active = EXCLUDED.is_active;

    -- Gemini 2.5 Pro
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
        'gemini-2.5-pro',
        'Gemini 2.5 Pro',
        'Modèle avancé de Google pour les tâches complexes avec capacités multimodales',
        'google',
        'google/gemini-2.5-pro',
        100,
        0.01,
        '{"model": "google/gemini-2.5-pro", "max_tokens": 1048500, "temperature": 1}'::jsonb,
        true,
        true,
        CURRENT_DATE + INTERVAL '30 days',
        '["Raisonnement avancé", "Multimodal", "Analyse complexe", "1M tokens de contexte"]'::jsonb,
        '{"rate_limit": "20 req/min", "max_output": "8192 tokens"}'::jsonb
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

    -- Ajouter les abilities pour Gemini 2.5 Pro
    INSERT INTO public.service_model_abilities (service_id, ability_id, cost_multiplier, is_active)
    SELECT 
        (SELECT id FROM public.ai_services WHERE slug = 'gemini-2.5-pro'),
        unnest(ARRAY[v_chat_ability_id, v_code_ability_id, v_creative_ability_id, v_reasoning_ability_id, v_vision_ability_id]),
        1.0,
        true
    ON CONFLICT (service_id, ability_id) DO UPDATE SET
        cost_multiplier = EXCLUDED.cost_multiplier,
        is_active = EXCLUDED.is_active;

    -- Gemini 2.5 Flash lite
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
        'gemini-2.5-flash-lite-preview-06-17',
        'Gemini 2.5 Flash Lite Preview 06-17',
        'Version optimisée pour la vitesse et l''efficacité',
        'google',
        'google/gemini-2.5-flash-lite-preview-06-17',
        8,
        0.000075,
        '{"model": "google/gemini-2.5-flash-lite-preview-06-17", "max_tokens": 8192, "temperature": 1}'::jsonb,
        true,
        true,
        CURRENT_DATE + INTERVAL '30 days',
        '["Très économique", "Rapide", "Optimisé", "1M tokens de contexte"]'::jsonb,
        '{"rate_limit": "100 req/min", "max_output": "1048000 tokens"}'::jsonb
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

    -- Ajouter les abilities pour Gemini 2.5 Flash lite
    INSERT INTO public.service_model_abilities (service_id, ability_id, cost_multiplier, is_active)
    SELECT 
        (SELECT id FROM public.ai_services WHERE slug = 'gemini-2.5-flash-lite-preview-06-17'),
        unnest(ARRAY[v_chat_ability_id, v_code_ability_id]),
        1.0,
        true
    ON CONFLICT (service_id, ability_id) DO UPDATE SET
        cost_multiplier = EXCLUDED.cost_multiplier,
        is_active = EXCLUDED.is_active;

    -- =====================================================
    -- GROK MODELS
    -- =====================================================

    -- Grok 4
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
        'grok-4',
        'Grok 4',
        'Modèle avancé de xAI avec capacités de raisonnement supérieures et accès temps réel',
        'xai',
        'x-ai/grok-4',
        50,
        0.005,
        '{"model": "x-ai/grok-4", "max_tokens": 256000, "temperature": 1}'::jsonb,
        true,
        true,
        CURRENT_DATE + INTERVAL '30 days',
        '["Accès temps réel", "Raisonnement avancé", "Analyse complexe", "Humour et personnalité"]'::jsonb,
        '{"rate_limit": "100 req/min", "max_output": "4096 tokens"}'::jsonb
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

    -- Ajouter les abilities pour Grok 4
    INSERT INTO public.service_model_abilities (service_id, ability_id, cost_multiplier, is_active)
    SELECT 
        (SELECT id FROM public.ai_services WHERE slug = 'grok-4'),
        unnest(ARRAY[v_chat_ability_id, v_code_ability_id, v_creative_ability_id, v_reasoning_ability_id]),
        1.0,
        true
    ON CONFLICT (service_id, ability_id) DO UPDATE SET
        cost_multiplier = EXCLUDED.cost_multiplier,
        is_active = EXCLUDED.is_active;

    -- Note: Grok 3 et Grok 3 Mini seront disponibles prochainement sur OpenRouter

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
    'gemini-2.5-flash',
    'gemini-2.5-pro',
    'gemini-2.5-flash-lite-preview-06-17',
    'grok-4'
)
GROUP BY s.name, s.provider, s.default_cost_points, s.api_cost_usd, s.is_active, s.is_new
ORDER BY s.provider, s.default_cost_points DESC;