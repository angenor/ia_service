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

-- Donner les permissions nécessaires
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON public.profiles TO postgres, service_role;
GRANT SELECT, UPDATE ON public.profiles TO authenticated;
GRANT SELECT ON public.profiles TO anon;