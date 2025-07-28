-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- TABLES DE BASE
-- =====================================================

-- Table des utilisateurs (profile étendu du auth.users de Supabase)
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE,
    display_name TEXT,
    country_code CHAR(2) NOT NULL,
    language_code VARCHAR(5) DEFAULT 'en',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    is_admin BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Table du wallet utilisateur
CREATE TABLE public.wallets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    balance INTEGER DEFAULT 0 CHECK (balance >= 0),
    currency VARCHAR(3) DEFAULT 'USD',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- =====================================================
-- TABLES DES SERVICES IA
-- =====================================================

-- Catégories de services
CREATE TABLE public.service_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sous-catégories de services (optionnelles)
CREATE TABLE public.service_subcategories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES public.service_categories(id) ON DELETE CASCADE,
    slug TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    -- Transformation metadata
    from_type TEXT,
    from_icon TEXT,
    to_type TEXT,
    to_icon TEXT,
    -- Other fields
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Services IA disponibles
CREATE TABLE public.ai_services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID REFERENCES public.service_categories(id),
    subcategory_id UUID REFERENCES public.service_subcategories(id),
    slug TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    provider TEXT NOT NULL,
    api_endpoint TEXT,
    icon TEXT,
    png TEXT,
    video TEXT,
    -- Prix minimum par défaut (défini par l'admin)
    default_cost_points INTEGER NOT NULL DEFAULT 0,
    api_cost_usd DECIMAL(10,6) DEFAULT 0,
    -- Configuration
    config JSONB DEFAULT '{}'::jsonb,
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_new BOOLEAN DEFAULT FALSE,
    new_until DATE,
    -- Metadata
    features JSONB DEFAULT '[]'::jsonb,
    limitations JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    -- Contrainte pour s'assurer qu'un service a soit une catégorie, soit une sous-catégorie
    CONSTRAINT service_category_check CHECK (
        (category_id IS NOT NULL AND subcategory_id IS NULL) OR
        (subcategory_id IS NOT NULL)
    )
);

-- Tarification par pays pour chaque service
CREATE TABLE public.service_pricing_by_country (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_id UUID NOT NULL REFERENCES public.ai_services(id) ON DELETE CASCADE,
    country_code CHAR(2) NOT NULL,
    cost_points INTEGER NOT NULL,
    -- Le prix ne peut pas être inférieur au prix minimum défini dans ai_services
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(service_id, country_code)
);

-- Disponibilité géographique des services
CREATE TABLE public.service_availability (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_id UUID NOT NULL REFERENCES public.ai_services(id) ON DELETE CASCADE,
    country_code CHAR(2) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(service_id, country_code)
);

-- =====================================================
-- TABLES DES TRANSACTIONS
-- =====================================================

-- Transactions de recharge du wallet
CREATE TABLE public.wallet_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wallet_id UUID NOT NULL REFERENCES public.wallets(id),
    amount INTEGER NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('deposit', 'purchase', 'refund', 'bonus')),
    payment_method VARCHAR(50),
    payment_reference TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'cancelled')),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

-- Utilisation des services (journal des consommations)
CREATE TABLE public.service_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id),
    service_id UUID NOT NULL REFERENCES public.ai_services(id),
    points_consumed INTEGER NOT NULL,
    country_code CHAR(2) NOT NULL, -- Ajout du pays pour traçabilité
    api_cost_usd DECIMAL(10,6),
    request_data JSONB DEFAULT '{}'::jsonb,
    response_data JSONB DEFAULT '{}'::jsonb,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    duration_ms INTEGER
);

-- =====================================================
-- TABLES DE TARIFICATION ET PROMOTIONS
-- =====================================================

-- Promotions et réductions
CREATE TABLE public.promotions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    discount_type VARCHAR(20) CHECK (discount_type IN ('percentage', 'fixed_points')),
    discount_value DECIMAL(10,2) NOT NULL,
    -- Conditions
    min_purchase_points INTEGER,
    max_uses_total INTEGER,
    max_uses_per_user INTEGER DEFAULT 1,
    valid_from TIMESTAMPTZ DEFAULT NOW(),
    valid_until TIMESTAMPTZ,
    -- Restrictions
    service_ids UUID[] DEFAULT '{}',
    country_codes CHAR(2)[] DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Utilisation des promotions
CREATE TABLE public.promotion_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    promotion_id UUID NOT NULL REFERENCES public.promotions(id),
    user_id UUID NOT NULL REFERENCES public.profiles(id),
    transaction_id UUID REFERENCES public.wallet_transactions(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(promotion_id, user_id, transaction_id)
);

-- =====================================================
-- TABLES D'ADMINISTRATION
-- =====================================================

-- Historique des prix par pays
CREATE TABLE public.price_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_id UUID NOT NULL REFERENCES public.ai_services(id),
    country_code CHAR(2),
    old_price_points INTEGER,
    new_price_points INTEGER NOT NULL,
    old_api_cost DECIMAL(10,6),
    new_api_cost DECIMAL(10,6),
    changed_by UUID REFERENCES public.profiles(id),
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Configuration système
CREATE TABLE public.system_config (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by UUID REFERENCES public.profiles(id)
);

-- =====================================================
-- VUES POUR L'ADMINISTRATION
-- =====================================================

-- Vue de rentabilité par service et par pays
CREATE OR REPLACE VIEW public.service_profitability AS
SELECT 
    s.id,
    s.name,
    s.provider,
    u.country_code,
    COALESCE(pc.cost_points, s.default_cost_points) as selling_price_points,
    s.api_cost_usd,
    COUNT(DISTINCT u.id) as total_uses,
    COUNT(DISTINCT u.user_id) as unique_users,
    SUM(u.points_consumed) as total_points_consumed,
    SUM(u.api_cost_usd) as total_api_cost,
    -- Calcul de la marge
    CASE 
        WHEN SUM(u.api_cost_usd) > 0 THEN
            ((SUM(u.points_consumed) * 0.01) - SUM(u.api_cost_usd)) / SUM(u.api_cost_usd) * 100
        ELSE 0
    END as profit_margin_percentage,
    DATE_TRUNC('day', u.created_at) as usage_date
FROM public.ai_services s
LEFT JOIN public.service_usage u ON s.id = u.service_id AND u.status = 'completed'
LEFT JOIN public.service_pricing_by_country pc ON s.id = pc.service_id AND u.country_code = pc.country_code
WHERE u.created_at >= NOW() - INTERVAL '30 days'
GROUP BY s.id, s.name, s.provider, u.country_code, pc.cost_points, s.default_cost_points, s.api_cost_usd, DATE_TRUNC('day', u.created_at);

-- Vue pour obtenir le prix effectif d'un service pour un pays donné
CREATE OR REPLACE VIEW public.service_effective_pricing AS
SELECT 
    s.id as service_id,
    s.slug as service_slug,
    s.name as service_name,
    c.country_code,
    COALESCE(spc.cost_points, s.default_cost_points) as effective_cost_points,
    s.api_cost_usd,
    CASE 
        WHEN spc.id IS NOT NULL THEN 'custom'
        ELSE 'default'
    END as pricing_type
FROM public.ai_services s
CROSS JOIN (SELECT DISTINCT country_code FROM public.profiles) c
LEFT JOIN public.service_pricing_by_country spc ON s.id = spc.service_id AND c.country_code = spc.country_code
WHERE s.is_active = true;

-- =====================================================
-- SÉCURITÉ - ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Activer RLS sur toutes les tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_subcategories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_pricing_by_country ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.promotions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.promotion_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.price_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_config ENABLE ROW LEVEL SECURITY;

-- Policies pour les utilisateurs (noms simplifiés et non récursifs)
CREATE POLICY "profiles_select_own" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "profiles_insert_own" ON public.profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update_own" ON public.profiles
    FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_delete_own" ON public.profiles
    FOR DELETE USING (auth.uid() = id);

CREATE POLICY "wallets_select_own" ON public.wallets
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "wallets_insert_own" ON public.wallets
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "wallets_update_own" ON public.wallets
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view active services" ON public.ai_services
    FOR SELECT USING (is_active = true);

CREATE POLICY "Users can view service categories" ON public.service_categories
    FOR SELECT USING (is_active = true);

CREATE POLICY "Users can view service subcategories" ON public.service_subcategories
    FOR SELECT USING (is_active = true);

CREATE POLICY "Users can view pricing for their country" ON public.service_pricing_by_country
    FOR SELECT USING (
        country_code = (SELECT country_code FROM public.profiles WHERE id = auth.uid())
    );

CREATE POLICY "Users can view own transactions" ON public.wallet_transactions
    FOR SELECT USING (wallet_id IN (SELECT id FROM public.wallets WHERE user_id = auth.uid()));

CREATE POLICY "Users can view own usage" ON public.service_usage
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can create usage records" ON public.service_usage
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Policies pour les administrateurs
CREATE POLICY "Admins can do everything on profiles" ON public.profiles
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
    );

CREATE POLICY "Admins can manage services" ON public.ai_services
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
    );

CREATE POLICY "Admins can manage categories" ON public.service_categories
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
    );

CREATE POLICY "Admins can manage subcategories" ON public.service_subcategories
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
    );

CREATE POLICY "Admins can manage pricing" ON public.service_pricing_by_country
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
    );

CREATE POLICY "Admins can view all wallets" ON public.wallets
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
    );

CREATE POLICY "Admins can manage promotions" ON public.promotions
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
    );

CREATE POLICY "Admins can view price history" ON public.price_history
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
    );

CREATE POLICY "Admins can manage system config" ON public.system_config
    FOR ALL USING (
        EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
    );

-- =====================================================
-- FONCTIONS ET TRIGGERS
-- =====================================================

-- Fonction pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers pour updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_wallets_updated_at BEFORE UPDATE ON public.wallets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ai_services_updated_at BEFORE UPDATE ON public.ai_services
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_service_pricing_updated_at BEFORE UPDATE ON public.service_pricing_by_country
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Fonction pour créer automatiquement un wallet lors de la création d'un profil
CREATE OR REPLACE FUNCTION create_user_wallet()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.wallets (user_id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER create_wallet_on_profile_insert
    AFTER INSERT ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION create_user_wallet();

-- Fonction pour créer automatiquement un profil utilisateur lors de l'inscription
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (
        id,
        username,
        display_name,
        country_code,
        language_code,
        metadata
    ) VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'country_code', 'US'),
        COALESCE(NEW.raw_user_meta_data->>'language_code', 'fr'),
        jsonb_build_object(
            'email', NEW.email,
            'phone', COALESCE(NEW.phone, ''),
            'provider', NEW.raw_app_meta_data->>'provider',
            'providers', NEW.raw_app_meta_data->'providers'
        )
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger pour exécuter la fonction lors de la création d'un nouvel utilisateur
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Fonction pour mettre à jour le profil lors de la mise à jour des données auth
CREATE OR REPLACE FUNCTION public.handle_user_update()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.profiles
    SET
        display_name = COALESCE(NEW.raw_user_meta_data->>'full_name', display_name),
        metadata = metadata || jsonb_build_object(
            'email', NEW.email,
            'phone', COALESCE(NEW.phone, ''),
            'email_confirmed_at', NEW.email_confirmed_at,
            'last_sign_in_at', NEW.last_sign_in_at,
            'updated_at', NOW()
        ),
        updated_at = NOW()
    WHERE id = NEW.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger pour mettre à jour le profil
CREATE TRIGGER on_auth_user_updated
    AFTER UPDATE ON auth.users
    FOR EACH ROW
    WHEN (OLD.* IS DISTINCT FROM NEW.*)
    EXECUTE FUNCTION public.handle_user_update();

-- Fonction pour vérifier que le prix par pays n'est pas inférieur au prix minimum
CREATE OR REPLACE FUNCTION check_minimum_price()
RETURNS TRIGGER AS $$
DECLARE
    v_default_price INTEGER;
BEGIN
    SELECT default_cost_points INTO v_default_price
    FROM public.ai_services
    WHERE id = NEW.service_id;
    
    IF NEW.cost_points < v_default_price THEN
        RAISE EXCEPTION 'Le prix par pays (%) ne peut pas être inférieur au prix minimum défini (%)', 
            NEW.cost_points, v_default_price;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_minimum_price
    BEFORE INSERT OR UPDATE ON public.service_pricing_by_country
    FOR EACH ROW EXECUTE FUNCTION check_minimum_price();

-- Fonction pour obtenir le prix effectif d'un service pour un utilisateur
CREATE OR REPLACE FUNCTION get_service_price_for_user(
    p_service_id UUID,
    p_user_id UUID
)
RETURNS INTEGER AS $$
DECLARE
    v_country_code CHAR(2);
    v_price INTEGER;
BEGIN
    -- Obtenir le pays de l'utilisateur
    SELECT country_code INTO v_country_code
    FROM public.profiles
    WHERE id = p_user_id;
    
    -- Obtenir le prix spécifique au pays, sinon le prix par défaut
    SELECT COALESCE(spc.cost_points, s.default_cost_points)
    INTO v_price
    FROM public.ai_services s
    LEFT JOIN public.service_pricing_by_country spc 
        ON s.id = spc.service_id AND spc.country_code = v_country_code
    WHERE s.id = p_service_id;
    
    RETURN v_price;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction améliorée pour déduire les points du wallet avec prix par pays
CREATE OR REPLACE FUNCTION deduct_wallet_points(
    p_user_id UUID,
    p_service_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
    v_wallet_id UUID;
    v_current_balance INTEGER;
    v_price INTEGER;
    v_country_code CHAR(2);
BEGIN
    -- Obtenir le pays de l'utilisateur
    SELECT country_code INTO v_country_code
    FROM public.profiles
    WHERE id = p_user_id;
    
    -- Obtenir le prix effectif pour ce pays
    v_price := get_service_price_for_user(p_service_id, p_user_id);
    
    -- Obtenir le wallet et vérifier le solde
    SELECT w.id, w.balance INTO v_wallet_id, v_current_balance
    FROM public.wallets w
    WHERE w.user_id = p_user_id
    FOR UPDATE;

    IF v_current_balance < v_price THEN
        RETURN FALSE;
    END IF;

    -- Déduire les points
    UPDATE public.wallets
    SET balance = balance - v_price
    WHERE id = v_wallet_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction RPC pour récupérer le profil utilisateur sans problème RLS
CREATE OR REPLACE FUNCTION public.get_user_profile(user_id UUID)
RETURNS TABLE (
    id UUID,
    username TEXT,
    display_name TEXT,
    country_code CHAR(2),
    language_code VARCHAR(5),
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    is_admin BOOLEAN,
    metadata JSONB
) 
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Vérifier que l'utilisateur demande son propre profil
    IF auth.uid() != user_id THEN
        RAISE EXCEPTION 'Unauthorized';
    END IF;
    
    RETURN QUERY
    SELECT 
        p.id,
        p.username,
        p.display_name,
        p.country_code,
        p.language_code,
        p.created_at,
        p.updated_at,
        p.is_admin,
        p.metadata
    FROM public.profiles p
    WHERE p.id = user_id;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- PERMISSIONS ET GRANTS
-- =====================================================

-- Donner les permissions nécessaires
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON public.profiles TO postgres, service_role;
GRANT SELECT, UPDATE ON public.profiles TO authenticated;
GRANT SELECT ON public.profiles TO anon;
GRANT EXECUTE ON FUNCTION public.get_user_profile(UUID) TO authenticated;

-- =====================================================
-- INDEX POUR LES PERFORMANCES
-- =====================================================

CREATE INDEX idx_profiles_country ON public.profiles(country_code);
CREATE INDEX idx_service_usage_user_date ON public.service_usage(user_id, created_at);
CREATE INDEX idx_service_usage_service_date ON public.service_usage(service_id, created_at);
CREATE INDEX idx_service_usage_country ON public.service_usage(country_code);
CREATE INDEX idx_wallet_transactions_wallet ON public.wallet_transactions(wallet_id);
CREATE INDEX idx_wallet_transactions_status ON public.wallet_transactions(status);
CREATE INDEX idx_ai_services_active ON public.ai_services(is_active);
CREATE INDEX idx_ai_services_category ON public.ai_services(category_id);
CREATE INDEX idx_ai_services_subcategory ON public.ai_services(subcategory_id);
CREATE INDEX idx_service_availability_country ON public.service_availability(country_code);
CREATE INDEX idx_service_pricing_country ON public.service_pricing_by_country(country_code);
CREATE INDEX idx_service_pricing_service ON public.service_pricing_by_country(service_id);
CREATE INDEX idx_promotions_code ON public.promotions(code);
CREATE INDEX idx_promotions_active_dates ON public.promotions(is_active, valid_from, valid_until);

-- =====================================================
-- DONNÉES INITIALES
-- =====================================================

-- Catégories de services
INSERT INTO public.service_categories (slug, name, sort_order) VALUES
('llm', 'Large Language Models', 1),
('video-generation', 'Génération de Vidéo', 2),
('image-generation', 'Génération d''Images', 3),
('audio-services', 'Services Audio', 4),
('dev-assistance', 'Assistance au Développement', 5),
('translation', 'Services de Traduction', 6),
('vision-analysis', 'Vision et Analyse', 7),
('search-rag', 'Recherche et RAG', 8),
('3d-avatars', '3D et Avatars', 9),
('document-processing', 'Traitement de Documents', 10),
('specialized', 'Services Spécialisés', 11);

-- Sous-catégories pour la génération de vidéo
INSERT INTO public.service_subcategories (category_id, slug, name, from_type, from_icon, to_type, to_icon, sort_order)
SELECT 
    id, 
    'text-to-video', 
    'Texte vers Vidéo',
    'text',
    'text-icon.png',
    'video',
    'video-icon.png',
    1
FROM public.service_categories WHERE slug = 'video-generation';

INSERT INTO public.service_subcategories (category_id, slug, name, from_type, from_icon, to_type, to_icon, sort_order)
SELECT 
    id, 
    'image-to-video', 
    'Image vers Vidéo',
    'image',
    'image-icon.png',
    'video',
    'video-icon.png',
    2
FROM public.service_categories WHERE slug = 'video-generation';

-- Sous-catégories pour les services audio
INSERT INTO public.service_subcategories (category_id, slug, name, from_type, from_icon, to_type, to_icon, sort_order)
SELECT 
    id, 
    'text-to-speech', 
    'Texte vers Parole',
    'text',
    'text-icon.png',
    'audio',
    'audio-icon.png',
    1
FROM public.service_categories WHERE slug = 'audio-services';

INSERT INTO public.service_subcategories (category_id, slug, name, from_type, from_icon, to_type, to_icon, sort_order)
SELECT 
    id, 
    'speech-to-text', 
    'Parole vers Texte',
    'audio',
    'audio-icon.png',
    'text',
    'text-icon.png',
    2
FROM public.service_categories WHERE slug = 'audio-services';

INSERT INTO public.service_subcategories (category_id, slug, name, from_type, from_icon, to_type, to_icon, sort_order)
SELECT 
    id, 
    'music-generation', 
    'Génération Musicale',
    'text',
    'text-icon.png',
    'music',
    'music-icon.png',
    3
FROM public.service_categories WHERE slug = 'audio-services';

-- Configuration système initiale
INSERT INTO public.system_config (key, value, description) VALUES
('points_per_dollar', '100'::jsonb, 'Number of points per USD'),
('min_wallet_recharge', '500'::jsonb, 'Minimum points for wallet recharge'),
('new_service_days', '30'::jsonb, 'Days to show new badge on services'),
('api_rate_limit', '{"requests_per_minute": 60}'::jsonb, 'API rate limiting configuration'),
('supported_countries', '["US", "CI", "FR", "CA", "GB", "DE", "JP", "BR", "IN"]'::jsonb, 'List of supported countries');