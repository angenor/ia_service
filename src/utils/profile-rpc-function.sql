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

-- Donner les permissions
GRANT EXECUTE ON FUNCTION public.get_user_profile(UUID) TO authenticated;