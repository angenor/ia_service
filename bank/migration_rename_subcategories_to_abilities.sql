-- =====================================================
-- MIGRATION: Renommer service_subcategories en service_abilities
-- =====================================================
-- 
-- Cette migration transforme l'architecture pour refléter la logique correcte:
-- Relation many-to-many entre modèles et capacités
--
-- AVANT: service_categories -> service_subcategories -> ai_services
-- APRÈS: service_categories -> ai_services <-> service_abilities (via table de liaison)
--

BEGIN;

-- =====================================================
-- 1. CRÉER LES NOUVELLES TABLES
-- =====================================================

-- Créer la table des capacités (indépendante des services)
CREATE TABLE public.service_abilities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID REFERENCES public.service_categories(id) ON DELETE CASCADE,
    slug TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    -- Metadata pour la transformation
    from_type TEXT,
    from_icon TEXT,
    to_type TEXT,
    to_icon TEXT,
    -- Configuration globale de cette capacité
    config JSONB DEFAULT '{}'::jsonb,
    -- Autres champs
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Créer la table de liaison many-to-many
CREATE TABLE public.service_model_abilities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_id UUID NOT NULL REFERENCES public.ai_services(id) ON DELETE CASCADE,
    ability_id UUID NOT NULL REFERENCES public.service_abilities(id) ON DELETE CASCADE,
    -- Modificateur de coût spécifique à ce modèle pour cette capacité
    cost_multiplier DECIMAL(3,2) DEFAULT 1.0,
    -- Configuration spécifique à ce modèle pour cette capacité
    config JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    -- Contrainte d'unicité
    UNIQUE(service_id, ability_id)
);

-- =====================================================
-- 2. MIGRER LES DONNÉES DE service_subcategories
-- =====================================================

-- D'abord, créer les capacités basées sur les anciennes sous-catégories
INSERT INTO public.service_abilities (
    category_id,
    slug,
    name,
    description,
    from_type,
    from_icon,
    to_type,
    to_icon,
    sort_order,
    is_active,
    created_at
)
SELECT DISTINCT
    sc.category_id,
    sc.slug,
    sc.name,
    sc.description,
    sc.from_type,
    sc.from_icon,
    sc.to_type,
    sc.to_icon,
    sc.sort_order,
    sc.is_active,
    NOW()
FROM public.service_subcategories sc;

-- Ensuite, créer les liaisons service-capacité
INSERT INTO public.service_model_abilities (
    service_id,
    ability_id,
    cost_multiplier,
    is_active,
    created_at
)
SELECT 
    s.id as service_id,
    sa.id as ability_id,
    1.0 as cost_multiplier, -- multiplicateur par défaut
    TRUE,
    NOW()
FROM public.ai_services s
JOIN public.service_subcategories sc ON s.subcategory_id = sc.id
JOIN public.service_abilities sa ON sa.slug = sc.slug
WHERE s.subcategory_id IS NOT NULL;

-- =====================================================
-- 3. METTRE À JOUR ai_services
-- =====================================================

-- Remettre les services qui étaient dans des sous-catégories directement dans leur catégorie
UPDATE public.ai_services 
SET 
    category_id = sc.category_id,
    subcategory_id = NULL,
    updated_at = NOW()
FROM public.service_subcategories sc
WHERE ai_services.subcategory_id = sc.id;

-- Supprimer la colonne subcategory_id de ai_services
ALTER TABLE public.ai_services DROP COLUMN subcategory_id;

-- Mettre à jour la contrainte pour s'assurer qu'un service a toujours une catégorie
ALTER TABLE public.ai_services DROP CONSTRAINT IF EXISTS service_category_check;
ALTER TABLE public.ai_services ADD CONSTRAINT service_category_check CHECK (category_id IS NOT NULL);

-- =====================================================
-- 4. SUPPRIMER L'ANCIENNE TABLE service_subcategories
-- =====================================================

-- Supprimer les policies de l'ancienne table
DROP POLICY IF EXISTS "Service subcategories are viewable by everyone" ON public.service_subcategories;
DROP POLICY IF EXISTS "Admins can manage subcategories" ON public.service_subcategories;

-- Supprimer l'ancienne table
DROP TABLE public.service_subcategories CASCADE;

-- =====================================================
-- 5. CONFIGURER LA SÉCURITÉ RLS
-- =====================================================

-- Activer RLS
ALTER TABLE public.service_abilities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_model_abilities ENABLE ROW LEVEL SECURITY;

-- Policies pour les utilisateurs
CREATE POLICY "Service abilities are viewable by everyone" ON public.service_abilities
    FOR SELECT USING (is_active = true);

CREATE POLICY "Service model abilities are viewable by everyone" ON public.service_model_abilities
    FOR SELECT USING (is_active = true);

-- Policies pour les administrateurs
CREATE POLICY "Admins can manage abilities" ON public.service_abilities
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

CREATE POLICY "Admins can manage service model abilities" ON public.service_model_abilities
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE id = auth.uid() AND is_admin = true
        )
    );

-- =====================================================
-- 6. CRÉER LES INDEX POUR LES PERFORMANCES
-- =====================================================

CREATE INDEX idx_service_abilities_category ON public.service_abilities(category_id);
CREATE INDEX idx_service_abilities_active ON public.service_abilities(is_active);
CREATE INDEX idx_service_abilities_slug ON public.service_abilities(slug);

-- Index pour la table de liaison
CREATE INDEX idx_service_model_abilities_service ON public.service_model_abilities(service_id);
CREATE INDEX idx_service_model_abilities_ability ON public.service_model_abilities(ability_id);
CREATE INDEX idx_service_model_abilities_active ON public.service_model_abilities(is_active);

-- =====================================================
-- 7. CRÉER LES TRIGGERS
-- =====================================================

-- Triggers pour updated_at
CREATE TRIGGER update_service_abilities_updated_at 
    BEFORE UPDATE ON public.service_abilities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_service_model_abilities_updated_at 
    BEFORE UPDATE ON public.service_model_abilities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 8. FONCTIONS UTILITAIRES
-- =====================================================

-- Fonction pour obtenir les capacités d'un service
CREATE OR REPLACE FUNCTION get_service_abilities(p_service_id UUID)
RETURNS TABLE (
    id UUID,
    slug TEXT,
    name TEXT,
    description TEXT,
    from_type TEXT,
    to_type TEXT,
    cost_multiplier DECIMAL,
    is_active BOOLEAN
) 
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sa.id,
        sa.slug,
        sa.name,
        sa.description,
        sa.from_type,
        sa.to_type,
        sma.cost_multiplier,
        sma.is_active
    FROM public.service_abilities sa
    JOIN public.service_model_abilities sma ON sa.id = sma.ability_id
    WHERE sma.service_id = p_service_id
    AND sa.is_active = true
    AND sma.is_active = true
    ORDER BY sa.sort_order;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour calculer le coût d'une capacité spécifique pour un service donné
CREATE OR REPLACE FUNCTION get_service_ability_cost_for_user(
    p_service_id UUID,
    p_ability_id UUID,
    p_user_id UUID
)
RETURNS INTEGER AS $$
DECLARE
    v_base_cost INTEGER;
    v_multiplier DECIMAL;
    v_final_cost INTEGER;
BEGIN
    -- Obtenir le coût de base du service et le multiplicateur de la capacité
    SELECT 
        get_service_price_for_user(p_service_id, p_user_id),
        sma.cost_multiplier
    INTO v_base_cost, v_multiplier
    FROM public.service_model_abilities sma
    WHERE sma.service_id = p_service_id 
    AND sma.ability_id = p_ability_id
    AND sma.is_active = true;
    
    -- Calculer le coût final
    v_final_cost := CEIL(v_base_cost * v_multiplier);
    
    RETURN v_final_cost;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour obtenir tous les services qui ont une capacité donnée
CREATE OR REPLACE FUNCTION get_services_with_ability(p_ability_id UUID)
RETURNS TABLE (
    service_id UUID,
    service_name TEXT,
    service_slug TEXT,
    provider TEXT,
    cost_multiplier DECIMAL,
    is_available BOOLEAN
) 
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id,
        s.name,
        s.slug,
        s.provider,
        sma.cost_multiplier,
        sma.is_active
    FROM public.ai_services s
    JOIN public.service_model_abilities sma ON s.id = sma.service_id
    WHERE sma.ability_id = p_ability_id
    AND s.is_active = true
    AND sma.is_active = true
    ORDER BY s.name;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 9. CRÉER LES VUES
-- =====================================================

-- Vue pour afficher les services avec leurs capacités
CREATE OR REPLACE VIEW public.services_with_abilities AS
SELECT 
    s.id as service_id,
    s.slug as service_slug,
    s.name as service_name,
    s.provider,
    c.name as category_name,
    sa.id as ability_id,
    sa.slug as ability_slug,
    sa.name as ability_name,
    sa.from_type,
    sa.to_type,
    sma.cost_multiplier,
    s.default_cost_points,
    CEIL(s.default_cost_points * sma.cost_multiplier) as ability_cost_points,
    s.is_active as service_active,
    sma.is_active as ability_active
FROM public.ai_services s
JOIN public.service_categories c ON s.category_id = c.id
LEFT JOIN public.service_model_abilities sma ON s.id = sma.service_id
LEFT JOIN public.service_abilities sa ON sma.ability_id = sa.id
WHERE s.is_active = true
ORDER BY c.sort_order, s.name, sa.sort_order;

-- Vue pour afficher les capacités avec les services qui les supportent
CREATE OR REPLACE VIEW public.abilities_with_services AS
SELECT 
    sa.id as ability_id,
    sa.slug as ability_slug,
    sa.name as ability_name,
    sa.description as ability_description,
    sa.from_type,
    sa.to_type,
    c.name as category_name,
    s.id as service_id,
    s.slug as service_slug,
    s.name as service_name,
    s.provider,
    sma.cost_multiplier,
    s.default_cost_points,
    CEIL(s.default_cost_points * sma.cost_multiplier) as ability_cost_points,
    sa.is_active as ability_active,
    sma.is_active as service_ability_active
FROM public.service_abilities sa
JOIN public.service_categories c ON sa.category_id = c.id
LEFT JOIN public.service_model_abilities sma ON sa.id = sma.ability_id
LEFT JOIN public.ai_services s ON sma.service_id = s.id
WHERE sa.is_active = true
ORDER BY c.sort_order, sa.sort_order, s.name;

-- =====================================================
-- 10. PERMISSIONS
-- =====================================================

GRANT SELECT ON public.service_abilities TO authenticated, anon;
GRANT SELECT ON public.service_model_abilities TO authenticated, anon;
GRANT ALL ON public.service_abilities TO postgres, service_role;
GRANT ALL ON public.service_model_abilities TO postgres, service_role;
GRANT EXECUTE ON FUNCTION get_service_abilities(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_service_ability_cost_for_user(UUID, UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_services_with_ability(UUID) TO authenticated;

-- Donner les permissions sur les nouvelles vues
GRANT SELECT ON public.services_with_abilities TO authenticated, anon;
GRANT SELECT ON public.abilities_with_services TO authenticated, anon;

-- =====================================================
-- 11. COMMENTAIRES
-- =====================================================

COMMENT ON TABLE public.service_abilities IS 'Capacités d''IA disponibles - peuvent être partagées par plusieurs services';
COMMENT ON COLUMN public.service_abilities.category_id IS 'Référence vers la catégorie parente';
COMMENT ON COLUMN public.service_abilities.slug IS 'Identifiant unique de la capacité';
COMMENT ON COLUMN public.service_abilities.name IS 'Nom de la capacité';
COMMENT ON COLUMN public.service_abilities.from_type IS 'Type d''entrée de la transformation';
COMMENT ON COLUMN public.service_abilities.to_type IS 'Type de sortie de la transformation';

COMMENT ON TABLE public.service_model_abilities IS 'Liaison many-to-many entre services et capacités';
COMMENT ON COLUMN public.service_model_abilities.service_id IS 'Référence vers le service IA';
COMMENT ON COLUMN public.service_model_abilities.ability_id IS 'Référence vers la capacité';
COMMENT ON COLUMN public.service_model_abilities.cost_multiplier IS 'Multiplicateur de coût pour ce service-capacité (1.0 = coût normal)';

COMMIT;

-- =====================================================
-- REQUÊTES DE VÉRIFICATION POST-MIGRATION
-- =====================================================

-- Vérifier la structure finale
SELECT 
    'Migration completed successfully' as status,
    (SELECT COUNT(*) FROM public.service_abilities) as abilities_count,
    (SELECT COUNT(*) FROM public.service_model_abilities) as service_ability_links,
    (SELECT COUNT(*) FROM public.ai_services WHERE category_id IS NOT NULL) as services_with_categories;

-- Afficher les capacités avec les services qui les supportent
SELECT 
    ability_name,
    ability_slug,
    from_type || ' → ' || to_type as transformation,
    service_name,
    provider,
    cost_multiplier,
    ability_cost_points
FROM public.abilities_with_services
WHERE ability_active = true AND service_ability_active = true
ORDER BY ability_name, service_name;

-- Statistiques par catégorie
SELECT 
    c.name as category_name,
    COUNT(DISTINCT s.id) as services_count,
    COUNT(DISTINCT sa.id) as abilities_count,
    COUNT(sma.id) as service_ability_links,
    AVG(sma.cost_multiplier) as avg_cost_multiplier
FROM public.service_categories c
LEFT JOIN public.ai_services s ON c.id = s.category_id
LEFT JOIN public.service_abilities sa ON c.id = sa.category_id
LEFT JOIN public.service_model_abilities sma ON s.id = sma.service_id AND sa.id = sma.ability_id
WHERE c.is_active = true
GROUP BY c.id, c.name
ORDER BY c.sort_order;