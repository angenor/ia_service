ERROR:  23502: null value in column "service_id" of relation "service_model_abilities" violates not-null constraint
DETAIL:  Failing row contains (34655d1a-0364-48b2-823b-4ed22f4337f5, null, c2b434d1-21bb-47be-8eb1-ccdad9cdbdc4, 1.00, {}, t, 2025-07-31 00:00:44.488848+00, 2025-07-31 00:00:44.488848+00).
CONTEXT:  SQL statement "INSERT INTO public.service_model_abilities (service_id, ability_id, cost_multiplier, is_active)
    SELECT 
        (SELECT id FROM public.ai_services WHERE slug = 'gemini-2-5-flash'),
        unnest(ARRAY[v_chat_ability_id, v_code_ability_id, v_creative_ability_id, v_vision_ability_id]),
        1.0,
        true
    ON CONFLICT (service_id, ability_id) DO UPDATE SET
        cost_multiplier = EXCLUDED.cost_multiplier,
        is_active = EXCLUDED.is_active"
PL/pgSQL function inline_code_block line 95 at SQL statement


Debug with Assistant

