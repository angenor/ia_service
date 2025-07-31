-- =====================================================
-- NETTOYAGE DES MODÈLES DUPLIQUÉS (Version compatible avec migration)
-- =====================================================
-- 
-- Ce script supprime les modèles dupliqués créés par seed_llm_subcategories.sql
-- IMPORTANT: Ce script doit être exécuté AVANT la migration vers service_abilities
-- car il nettoie les données dans l'ancienne structure
--

BEGIN;

-- =====================================================
-- 1. VÉRIFIER L'ÉTAT ACTUEL
-- =====================================================

-- Compter les services LLM avant nettoyage
SELECT 
    'Services LLM avant nettoyage' as status,
    COUNT(*) as count
FROM public.ai_services s
JOIN public.service_categories c ON s.category_id = c.id
WHERE c.slug = 'llm';

-- Lister tous les services LLM actuels
SELECT 
    s.slug,
    s.name,
    s.provider,
    CASE WHEN s.subcategory_id IS NOT NULL THEN 'avec sous-catégorie' ELSE 'sans sous-catégorie' END as type
FROM public.ai_services s
JOIN public.service_categories c ON s.category_id = c.id
WHERE c.slug = 'llm'
ORDER BY s.name;

-- =====================================================
-- 2. IDENTIFIER LES SERVICES À GARDER (MODÈLES DE BASE)
-- =====================================================

-- Créer une table temporaire avec les services de base à conserver
CREATE TEMP TABLE services_to_keep AS
SELECT DISTINCT ON (
    CASE 
        WHEN s.slug ~ '^claude-opus-4' THEN 'claude-opus-4'
        WHEN s.slug ~ '^claude-sonnet-4' THEN 'claude-sonnet-4'
        WHEN s.slug ~ '^gpt-4-turbo' THEN 'gpt-4-turbo'
        WHEN s.slug = 'gpt-4' THEN 'gpt-4'
        WHEN s.slug ~ '^grok' THEN 'grok'
        ELSE s.slug
    END
)
s.id,
s.slug,
s.name,
CASE 
    WHEN s.slug ~ '^claude-opus-4' THEN 'claude-opus-4'
    WHEN s.slug ~ '^claude-sonnet-4' THEN 'claude-sonnet-4'
    WHEN s.slug ~ '^gpt-4-turbo' THEN 'gpt-4-turbo'
    WHEN s.slug = 'gpt-4' THEN 'gpt-4'
    WHEN s.slug ~ '^grok' THEN 'grok'
    ELSE s.slug
END as base_model
FROM public.ai_services s
JOIN public.service_categories c ON s.category_id = c.id
WHERE c.slug = 'llm'
AND s.slug IN ('claude-opus-4', 'claude-sonnet-4', 'gpt-4-turbo', 'gpt-4', 'grok')
ORDER BY 
    CASE 
        WHEN s.slug ~ '^claude-opus-4' THEN 'claude-opus-4'
        WHEN s.slug ~ '^claude-sonnet-4' THEN 'claude-sonnet-4'
        WHEN s.slug ~ '^gpt-4-turbo' THEN 'gpt-4-turbo'
        WHEN s.slug = 'gpt-4' THEN 'gpt-4'
        WHEN s.slug ~ '^grok' THEN 'grok'
        ELSE s.slug
    END,
    s.created_at;

-- Afficher les services qui seront conservés
SELECT 
    'Services qui seront conservés:' as info,
    slug,
    name,
    base_model
FROM services_to_keep
ORDER BY base_model;

-- =====================================================
-- 3. SAUVEGARDER LES DONNÉES IMPORTANTES AVANT SUPPRESSION
-- =====================================================

-- Sauvegarder les pricing des services qui vont être supprimés vers les services conservés
UPDATE public.service_pricing_by_country 
SET service_id = stk.id
FROM services_to_keep stk,
     public.ai_services s
WHERE service_pricing_by_country.service_id = s.id
AND s.id NOT IN (SELECT id FROM services_to_keep)
AND (
    (s.slug ~ '^claude-opus-4' AND stk.base_model = 'claude-opus-4') OR
    (s.slug ~ '^claude-sonnet-4' AND stk.base_model = 'claude-sonnet-4') OR
    (s.slug ~ '^gpt-4-turbo' AND stk.base_model = 'gpt-4-turbo') OR
    (s.slug = 'gpt-4' AND stk.base_model = 'gpt-4') OR
    (s.slug ~ '^grok' AND stk.base_model = 'grok')
);

-- Sauvegarder les availability des services qui vont être supprimés
UPDATE public.service_availability 
SET service_id = stk.id
FROM services_to_keep stk,
     public.ai_services s
WHERE service_availability.service_id = s.id
AND s.id NOT IN (SELECT id FROM services_to_keep)
AND (
    (s.slug ~ '^claude-opus-4' AND stk.base_model = 'claude-opus-4') OR
    (s.slug ~ '^claude-sonnet-4' AND stk.base_model = 'claude-sonnet-4') OR
    (s.slug ~ '^gpt-4-turbo' AND stk.base_model = 'gpt-4-turbo') OR
    (s.slug = 'gpt-4' AND stk.base_model = 'gpt-4') OR
    (s.slug ~ '^grok' AND stk.base_model = 'grok')
);

-- =====================================================
-- 4. SUPPRIMER LES SERVICES DUPLIQUÉS
-- =====================================================

-- Supprimer tous les services LLM qui ne sont pas dans la liste à conserver
DELETE FROM public.ai_services 
WHERE category_id = (SELECT id FROM public.service_categories WHERE slug = 'llm')
AND id NOT IN (SELECT id FROM services_to_keep);

-- =====================================================
-- 5. NETTOYER LES DONNÉES ORPHELINES
-- =====================================================

-- Supprimer les pricing orphelins
DELETE FROM public.service_pricing_by_country 
WHERE service_id NOT IN (SELECT id FROM public.ai_services);

-- Supprimer les availability orphelins
DELETE FROM public.service_availability 
WHERE service_id NOT IN (SELECT id FROM public.ai_services);

-- Supprimer les service_usage orphelins
DELETE FROM public.service_usage 
WHERE service_id NOT IN (SELECT id FROM public.ai_services);

-- =====================================================
-- 6. VÉRIFICATIONS FINALES
-- =====================================================

-- Compter les services restants
SELECT 
    'Services LLM après nettoyage' as status,
    COUNT(*) as count
FROM public.ai_services s
JOIN public.service_categories c ON s.category_id = c.id
WHERE c.slug = 'llm';

-- Lister les services restants
SELECT 
    s.slug,
    s.name,
    s.provider,
    s.is_active,
    'Service de base conservé' as status
FROM public.ai_services s
JOIN public.service_categories c ON s.category_id = c.id
WHERE c.slug = 'llm'
ORDER BY s.name;

-- Vérifier qu'il n'y a plus de doublons par nom de base
SELECT 
    CASE 
        WHEN s.name ~ 'Claude Opus' THEN 'Claude Opus 4'
        WHEN s.name ~ 'Claude Sonnet' THEN 'Claude Sonnet 4'
        WHEN s.name ~ 'GPT-4 Turbo' THEN 'GPT-4 Turbo'
        WHEN s.name = 'GPT-4' THEN 'GPT-4'
        WHEN s.name ~ 'Grok' THEN 'Grok'
        ELSE s.name
    END as base_name,
    COUNT(*) as count
FROM public.ai_services s
JOIN public.service_categories c ON s.category_id = c.id
WHERE c.slug = 'llm'
GROUP BY 
    CASE 
        WHEN s.name ~ 'Claude Opus' THEN 'Claude Opus 4'
        WHEN s.name ~ 'Claude Sonnet' THEN 'Claude Sonnet 4'
        WHEN s.name ~ 'GPT-4 Turbo' THEN 'GPT-4 Turbo'
        WHEN s.name = 'GPT-4' THEN 'GPT-4'
        WHEN s.name ~ 'Grok' THEN 'Grok'
        ELSE s.name
    END
HAVING COUNT(*) > 1;

-- Nettoyer la table temporaire
DROP TABLE services_to_keep;

COMMIT;

-- =====================================================
-- RAPPORT FINAL
-- =====================================================

SELECT 
    'NETTOYAGE TERMINÉ - PRÊT POUR LA MIGRATION' as status,
    (SELECT COUNT(*) FROM public.ai_services s JOIN public.service_categories c ON s.category_id = c.id WHERE c.slug = 'llm') as modeles_llm_restants,
    (SELECT COUNT(*) FROM public.service_pricing_by_country spc JOIN public.ai_services s ON spc.service_id = s.id JOIN public.service_categories c ON s.category_id = c.id WHERE c.slug = 'llm') as prix_llm_par_pays,
    (SELECT COUNT(*) FROM public.service_availability sa JOIN public.ai_services s ON sa.service_id = s.id JOIN public.service_categories c ON s.category_id = c.id WHERE c.slug = 'llm') as disponibilites_llm;