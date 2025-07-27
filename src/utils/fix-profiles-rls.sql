-- Désactiver temporairement RLS pour corriger les politiques
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- Supprimer toutes les politiques existantes sur profiles
DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
DROP POLICY IF EXISTS "Enable read access for all users" ON public.profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.profiles;
DROP POLICY IF EXISTS "Enable update for users based on id" ON public.profiles;

-- Créer des politiques simples et non récursives
-- Politique pour SELECT
CREATE POLICY "Enable select for users based on user_id" 
ON public.profiles FOR SELECT 
USING (
    auth.uid() = id OR 
    EXISTS (
        SELECT 1 FROM auth.users 
        WHERE auth.users.id = profiles.id
    )
);

-- Politique pour INSERT (géré par le trigger, mais au cas où)
CREATE POLICY "Enable insert for authenticated users" 
ON public.profiles FOR INSERT 
WITH CHECK (auth.uid() = id);

-- Politique pour UPDATE
CREATE POLICY "Enable update for users based on user_id" 
ON public.profiles FOR UPDATE 
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Politique pour DELETE (généralement pas nécessaire car CASCADE depuis auth.users)
CREATE POLICY "Enable delete for users based on user_id" 
ON public.profiles FOR DELETE 
USING (auth.uid() = id);

-- Réactiver RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Faire de même pour la table wallets si nécessaire
ALTER TABLE public.wallets DISABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own wallet" ON public.wallets;
DROP POLICY IF EXISTS "Users can update their own wallet" ON public.wallets;
DROP POLICY IF EXISTS "Enable read access for users" ON public.wallets;
DROP POLICY IF EXISTS "Enable all for users based on user_id" ON public.wallets;

-- Politiques pour wallets
CREATE POLICY "Enable select for wallet owner" 
ON public.wallets FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Enable update for wallet owner" 
ON public.wallets FOR UPDATE 
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- INSERT est géré par trigger, mais au cas où
CREATE POLICY "Enable insert for wallet owner" 
ON public.wallets FOR INSERT 
WITH CHECK (auth.uid() = user_id);

ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;

-- Vérifier que les fonctions ne causent pas de récursion
-- S'assurer que les triggers utilisent SECURITY DEFINER correctement
ALTER FUNCTION public.handle_new_user() SECURITY DEFINER;
ALTER FUNCTION public.handle_user_update() SECURITY DEFINER;
ALTER FUNCTION public.create_user_wallet() SECURITY DEFINER;