-- =====================================================
-- Ajout des modèles DeepSeek, Qwen, GPT-4.5, GPT-4.1 et Llama 4
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
    -- DEEPSEEK MODELS
    -- =====================================================

    -- DeepSeek V3 0324 (Free)
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
        'deepseek-chat-v3-0324-free',
        'DeepSeek V3 0324 (Free)',
        'Modèle mixture-of-experts de 685B paramètres, gratuit et performant',
        'deepseek',
        'deepseek/deepseek-chat-v3-0324:free',
        0,
        0.0,
        '{"model": "deepseek/deepseek-chat-v3-0324:free", "max_tokens": 16384, "temperature": 0.7}'::jsonb,
        true,
        true,
        CURRENT_DATE + INTERVAL '30 days',
        '["Gratuit", "685B paramètres", "32k tokens de contexte", "FP8 quantization"]'::jsonb,
        '{"rate_limit": "10 req/min", "max_output": "16384 tokens", "text_only": true}'::jsonb
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

    -- Ajouter les abilities pour DeepSeek V3
    INSERT INTO public.service_model_abilities (service_id, ability_id, cost_multiplier, is_active)
    SELECT 
        (SELECT id FROM public.ai_services WHERE slug = 'deepseek-chat-v3-0324-free'),
        unnest(ARRAY[v_chat_ability_id, v_code_ability_id, v_creative_ability_id, v_reasoning_ability_id]),
        1.0,
        true
    ON CONFLICT (service_id, ability_id) DO UPDATE SET
        cost_multiplier = EXCLUDED.cost_multiplier,
        is_active = EXCLUDED.is_active;

    -- =====================================================
    -- QWEN MODELS
    -- =====================================================

    -- Qwen3 Coder (Free)
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
        'qwen3-coder-free',
        'Qwen3 Coder (Free)',
        'Modèle optimisé pour le codage avec 480B paramètres (35B actifs)',
        'qwen',
        'qwen/qwen3-coder:free',
        0,
        0.0,
        '{"model": "qwen/qwen3-coder:free", "max_tokens": 4096, "temperature": 0.7}'::jsonb,
        true,
        true,
        CURRENT_DATE + INTERVAL '30 days',
        '["Gratuit", "Optimisé codage", "262k tokens de contexte", "Function calling", "Tool use"]'::jsonb,
        '{"rate_limit": "10 req/min", "max_output": "4096 tokens", "pricing_note": "Peut changer pour requêtes >128k"}'::jsonb
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

    -- Ajouter les abilities pour Qwen3 Coder
    INSERT INTO public.service_model_abilities (service_id, ability_id, cost_multiplier, is_active)
    SELECT 
        (SELECT id FROM public.ai_services WHERE slug = 'qwen3-coder-free'),
        unnest(ARRAY[v_chat_ability_id, v_code_ability_id, v_reasoning_ability_id]),
        1.0,
        true
    ON CONFLICT (service_id, ability_id) DO UPDATE SET
        cost_multiplier = EXCLUDED.cost_multiplier,
        is_active = EXCLUDED.is_active;

    -- =====================================================
    -- OPENAI MODELS
    -- =====================================================

    -- GPT-4.5 Preview
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
        'gpt-4-5-preview',
        'GPT-4.5 Preview',
        'Modèle de recherche avec capacités de raisonnement et créativité améliorées',
        'openai',
        'openai/gpt-4.5-preview',
        100,
        0.01,
        '{"model": "openai/gpt-4.5-preview", "max_tokens": 4096, "temperature": 0.7}'::jsonb,
        true,
        true,
        CURRENT_DATE + INTERVAL '30 days',
        '["Research preview", "Raisonnement amélioré", "Créativité avancée", "128k tokens de contexte", "Multimodal"]'::jsonb,
        '{"rate_limit": "20 req/min", "max_output": "4096 tokens", "image_support": true}'::jsonb
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

    -- Ajouter les abilities pour GPT-4.5 Preview
    INSERT INTO public.service_model_abilities (service_id, ability_id, cost_multiplier, is_active)
    SELECT 
        (SELECT id FROM public.ai_services WHERE slug = 'gpt-4-5-preview'),
        unnest(ARRAY[v_chat_ability_id, v_code_ability_id, v_creative_ability_id, v_reasoning_ability_id, v_vision_ability_id]),
        1.0,
        true
    ON CONFLICT (service_id, ability_id) DO UPDATE SET
        cost_multiplier = EXCLUDED.cost_multiplier,
        is_active = EXCLUDED.is_active;

    -- GPT-4.1
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
        'gpt-4-1',
        'GPT-4.1',
        'Modèle avancé avec contexte de 1M tokens et support multimodal',
        'openai',
        'openai/gpt-4.1',
        20,
        0.002,
        '{"model": "openai/gpt-4.1", "max_tokens": 32768, "temperature": 0.7}'::jsonb,
        true,
        true,
        CURRENT_DATE + INTERVAL '30 days',
        '["1M tokens de contexte", "Multimodal", "SWE-bench 54.6%", "87.4% compliance", "Support fichiers"]'::jsonb,
        '{"rate_limit": "30 req/min", "max_output": "32768 tokens", "image_support": true, "moderation_required": true}'::jsonb
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

    -- Ajouter les abilities pour GPT-4.1
    INSERT INTO public.service_model_abilities (service_id, ability_id, cost_multiplier, is_active)
    SELECT 
        (SELECT id FROM public.ai_services WHERE slug = 'gpt-4-1'),
        unnest(ARRAY[v_chat_ability_id, v_code_ability_id, v_creative_ability_id, v_reasoning_ability_id, v_vision_ability_id]),
        1.0,
        true
    ON CONFLICT (service_id, ability_id) DO UPDATE SET
        cost_multiplier = EXCLUDED.cost_multiplier,
        is_active = EXCLUDED.is_active;

    -- =====================================================
    -- META LLAMA MODELS
    -- =====================================================

    -- Llama 4 Maverick
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
        'llama-4-maverick',
        'Llama 4 Maverick',
        'Modèle mixture-of-experts avec 128 experts et support multimodal',
        'meta-llama',
        'meta-llama/llama-4-maverick-17b-128e-instruct',
        2,
        0.00015,
        '{"model": "meta-llama/llama-4-maverick-17b-128e-instruct", "max_tokens": 4096, "temperature": 0.7}'::jsonb,
        true,
        true,
        CURRENT_DATE + INTERVAL '30 days',
        '["1M tokens de contexte", "128 experts", "17B params actifs", "12 langues", "Multimodal", "FP8"]'::jsonb,
        '{"rate_limit": "100 req/min", "max_output": "4096 tokens", "image_support": true, "max_images": 1}'::jsonb
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

    -- Ajouter les abilities pour Llama 4 Maverick
    INSERT INTO public.service_model_abilities (service_id, ability_id, cost_multiplier, is_active)
    SELECT 
        (SELECT id FROM public.ai_services WHERE slug = 'llama-4-maverick'),
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
    'deepseek-chat-v3-0324-free',
    'qwen3-coder-free',
    'gpt-4-5-preview',
    'gpt-4-1',
    'llama-4-maverick'
)
GROUP BY s.name, s.provider, s.default_cost_points, s.api_cost_usd, s.is_active, s.is_new
ORDER BY s.provider, s.default_cost_points DESC;