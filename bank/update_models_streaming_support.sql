-- Mise à jour du support de streaming pour les modèles connus
-- Basé sur la documentation OpenRouter et les modèles ajoutés

-- D'abord, s'assurer que tous les modèles ont la valeur par défaut (true)
UPDATE ai_services 
SET supports_streaming = true 
WHERE supports_streaming IS NULL;

-- =====================================================
-- MODÈLES QUI SUPPORTENT LE STREAMING
-- =====================================================

-- Modèles confirmés avec support de streaming
UPDATE ai_services 
SET supports_streaming = true 
WHERE api_endpoint IN (
    -- ===== ANTHROPIC/CLAUDE =====
    'anthropic/claude-3-opus',
    'anthropic/claude-3-sonnet',
    'anthropic/claude-3-haiku',
    'anthropic/claude-sonnet-4',
    'anthropic/claude-opus-4',
    
    -- ===== OPENAI =====
    'openai/gpt-4-turbo',
    'openai/gpt-4',
    'openai/gpt-3.5-turbo',
    'openai/chatgpt-4o-latest',
    'openai/gpt-4.5-preview',
    'openai/gpt-4.1',
    
    -- ===== GOOGLE GEMINI =====
    'google/gemini-pro',
    'google/gemini-2.5-flash',
    'google/gemini-2.5-pro',
    'google/gemini-2.5-flash-lite-preview-06-17',
    'google/gemini-flash-1.5',
    
    -- ===== META LLAMA =====
    'meta-llama/llama-3-70b-instruct',
    'meta-llama/llama-3-8b-instruct',
    'meta-llama/llama-4-maverick-17b-128e-instruct',
    
    -- ===== MISTRAL =====
    'mistralai/mistral-7b-instruct',
    'mistralai/mixtral-8x7b-instruct',
    
    -- ===== XAI GROK =====
    'x-ai/grok-4',
    'x-ai/grok-3',
    'x-ai/grok-3-mini',
    
    -- ===== DEEPSEEK =====
    'deepseek/deepseek-chat-v3-0324:free',
    
    -- ===== QWEN =====
    'qwen/qwen3-coder:free'
);

-- =====================================================
-- MODÈLES QUI NE SUPPORTENT PAS LE STREAMING
-- =====================================================

-- Modèles connus pour ne PAS supporter le streaming
-- (Décommentez et ajoutez les modèles qui ne supportent pas le streaming)
/*
UPDATE ai_services 
SET supports_streaming = false 
WHERE api_endpoint IN (
    -- Exemple : certains modèles spécialisés ou plus anciens
    -- 'provider/model-without-streaming'
);
*/

-- Pour l'instant, tous les modèles listés supportent le streaming
-- Si vous découvrez qu'un modèle ne supporte pas le streaming, utilisez :
-- UPDATE ai_services SET supports_streaming = false WHERE api_endpoint = 'provider/model-name';

-- =====================================================
-- VÉRIFICATION
-- =====================================================

-- Afficher le statut de streaming pour tous les modèles
SELECT 
    name as model_name,
    provider,
    api_endpoint,
    supports_streaming,
    CASE 
        WHEN supports_streaming = true THEN '✅ Streaming activé'
        WHEN supports_streaming = false THEN '❌ Streaming désactivé'
        ELSE '⚠️ Non défini'
    END as streaming_status
FROM ai_services
WHERE category_id = (SELECT id FROM service_categories WHERE slug = 'llm')
ORDER BY provider, name;

-- Note: Si vous découvrez qu'un modèle ne supporte pas le streaming,
-- vous pouvez le désactiver avec :
-- UPDATE ai_services SET supports_streaming = false WHERE api_endpoint = 'provider/model-name';