-- Script pour corriger définitivement les politiques RLS de la table profiles
-- Exécuter ce script dans la console SQL de Supabase

-- 1. Désactiver RLS temporairement
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- 2. Supprimer TOUTES les politiques existantes
DO $$ 
DECLARE 
    policy_name TEXT;
BEGIN
    FOR policy_name IN 
        SELECT polname FROM pg_policy WHERE polrelid = 'public.profiles'::regclass
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(policy_name) || ' ON public.profiles';
    END LOOP;
END $$;

-- 3. Créer des politiques simples et non récursives

-- Politique SELECT : Les utilisateurs peuvent voir leur propre profil
CREATE POLICY "profiles_select_own" 
ON public.profiles FOR SELECT 
USING (auth.uid() = id);

-- Politique INSERT : Les utilisateurs peuvent créer leur propre profil
CREATE POLICY "profiles_insert_own" 
ON public.profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

-- Politique UPDATE : Les utilisateurs peuvent mettre à jour leur propre profil
CREATE POLICY "profiles_update_own" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Politique DELETE : Les utilisateurs peuvent supprimer leur propre profil
CREATE POLICY "profiles_delete_own" 
ON public.profiles FOR DELETE 
USING (auth.uid() = id);

-- 4. Réactiver RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 5. Vérifier que les politiques sont bien créées
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'profiles';

-- 6. Tester l'accès (optionnel - décommenter pour tester)
-- SELECT * FROM public.profiles WHERE id = auth.uid();

-- 7. Si la table wallets a aussi des problèmes, appliquer la même logique
ALTER TABLE public.wallets DISABLE ROW LEVEL SECURITY;

DO $$ 
DECLARE 
    policy_name TEXT;
BEGIN
    FOR policy_name IN 
        SELECT polname FROM pg_policy WHERE polrelid = 'public.wallets'::regclass
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(policy_name) || ' ON public.wallets';
    END LOOP;
END $$;

-- Politiques pour wallets
CREATE POLICY "wallets_select_own" 
ON public.wallets FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "wallets_insert_own" 
ON public.wallets FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "wallets_update_own" 
ON public.wallets FOR UPDATE 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;