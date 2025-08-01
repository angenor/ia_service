-- Ajouter la colonne supports_streaming à la table ai_services
ALTER TABLE ai_services 
ADD COLUMN IF NOT EXISTS supports_streaming BOOLEAN DEFAULT TRUE;

-- Commentaire sur la colonne
COMMENT ON COLUMN ai_services.supports_streaming IS 'Indique si le modèle supporte le streaming SSE. Par défaut activé.';

-- Mettre à jour les modèles connus qui ne supportent PAS le streaming
-- (Ajoutez ici les modèles qui ne supportent pas le streaming)
-- Exemple hypothétique :
-- UPDATE ai_services 
-- SET supports_streaming = false 
-- WHERE slug IN ('some-model-without-streaming');

-- Par défaut, tous les modèles existants supportent le streaming
UPDATE ai_services 
SET supports_streaming = true 
WHERE supports_streaming IS NULL;