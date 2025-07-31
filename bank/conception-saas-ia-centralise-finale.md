# Document de Conception - SaaS d'IA Centralisé

## 1. Vue d'ensemble du projet

### 1.1 Description

Plateforme SaaS centralisée offrant un accès unifié à plusieurs services d'IA via une interface unique, avec système de points et gestion multi-plateforme.

### 1.2 Objectifs principaux

- Centraliser l'accès à multiples services d'IA
- Simplifier la tarification avec un système de points unifié
- Offrir une expérience utilisateur cohérente sur web et mobile
- Gérer la disponibilité géographique des services
- Optimiser la rentabilité avec une gestion dynamique des prix par pays

## 2. Architecture technique

### 2.1 Stack technologique

- **Frontend Web**: Vue.js 3
- **Frontend Mobile**: Flutter
- **Backend**: Supabase (PostgreSQL avec RLS)
- **APIs IA**:
  - OpenRouter (pour les LLMs)
  - fal.ai (pour les autres services)
  - APIs propriétaires des différents services
- **Paiement**: API unifiée propriétaire (Mobile Money, cartes bancaires)
- **Base de données**: PostgreSQL avec extensions UUID et pgcrypto

### 2.2 Évolution prévue

- Court terme: Utilisation d'APIs tierces
- Moyen/Long terme: Déploiement de modèles open source Hugging Face sur serveurs dédiés

## 3. Fonctionnalités principales

### 3.1 Système d'authentification

- **Méthode principale**: Connexion via Google ou Apple
- **Méthode alternative**: Formulaire classique
  - Username (unique)
  - Display name
  - Email (géré par Supabase Auth)
  - Mot de passe
  - Pays (code ISO 2 caractères, obligatoire)
  - Langue préférée (par défaut: anglais)

### 3.2 Système de points et wallet

- **Wallet utilisateur** avec points prépayés
  - Création automatique à l'inscription
  - Balance en points (entiers positifs)
  - Devise de référence (USD par défaut)
- **Types de transactions**:
  - Dépôt (deposit)
  - Achat de service (purchase)
  - Remboursement (refund)
  - Bonus (bonus)
- **Statuts de transaction**: pending, completed, failed, cancelled
- Méthodes de paiement:
  - Mobile Money (API propriétaire initiale)
  - Cartes bancaires
  - Développement futur d'outils de paiement propriétaires

### 3.3 Gestion des services IA

#### 3.3.1 Structure hiérarchique

**Architecture en 3 niveaux avec relation many-to-many:**
- **Catégories principales**: Organisation des services par type (ex: LLM, Génération d'images, etc.)
- **Services IA (Modèles)**: Les modèles spécifiques dans chaque catégorie (ex: Claude, GPT-4, etc.)
- **Capacités**: Les capacités disponibles qui peuvent être partagées par plusieurs modèles

**Relations:**
- Une catégorie contient plusieurs modèles (`service_categories` → `ai_services`)
- Une catégorie définit plusieurs capacités (`service_categories` → `service_abilities`)
- **Relation many-to-many**: Un modèle peut avoir plusieurs capacités, et une capacité peut être supportée par plusieurs modèles
- Table de liaison: `service_model_abilities` pour gérer les associations modèle-capacité

**Avantages de cette architecture:**
- **Flexibilité**: Une capacité comme "chat-assistant" peut être partagée par Claude, GPT-4, Grok
- **Tarification précise**: Chaque association modèle-capacité a son propre multiplicateur de coût
- **Évolutivité**: Facile d'ajouter de nouvelles capacités ou d'associer des capacités existantes à de nouveaux modèles

**Capacités (service_abilities):**
- Définition globale des capacités par catégorie
- Metadata de transformation: type source → type destination
- Icônes spécifiques pour chaque type
- Configuration globale via JSONB

**Liaison modèle-capacité (service_model_abilities):**
- Multiplicateur de coût spécifique à la combinaison modèle-capacité
- Configuration spécifique à cette association
- Activation/désactivation par association

#### 3.3.2 Tarification dynamique par pays

- **Prix de base** (default_cost_points): Prix minimum défini par l'admin
- **Prix par pays**: Possibilité de définir des prix spécifiques
  - Ne peut jamais être inférieur au prix de base
  - Appliqué automatiquement selon le pays de l'utilisateur
- **Coût API** (api_cost_usd): Pour le calcul de rentabilité

#### 3.3.3 Gestion des modèles

- Badge "Nouveau" pour les modèles récemment ajoutés
  - Date de fin configurable (new_until)
- Configuration flexible via JSONB (config)
- Features et limitations documentées
- Support des réductions et promotions avec affichage clair

### 3.4 Disponibilité géographique

- **Gestion par service**: Chaque service peut être activé/désactivé par pays
- **Liste des pays supportés** (configuration système)
- Détection automatique du pays de l'utilisateur
- Restrictions appliquées automatiquement

### 3.5 Système de promotions

- **Types de réductions**:
  - Pourcentage
  - Points fixes
- **Conditions**:
  - Achat minimum en points
  - Nombre d'utilisations maximum (total et par utilisateur)
  - Période de validité
- **Restrictions**:
  - Par service(s) spécifique(s)
  - Par pays
- Codes promotionnels uniques

### 3.6 Interface d'administration (Web uniquement)

#### 3.6.1 Dashboard de rentabilité

- **Vue service_profitability** avec métriques en temps réel:
  - Coût facturé par l'API (prix d'achat)
  - Prix facturé au client (prix de vente)
  - Marge bénéficiaire calculée automatiquement
  - Statistiques d'utilisation par modèle et par pays
  - Analyse sur 30 jours glissants

#### 3.6.2 Gestion des services

- Configuration des catégories de services
- Gestion des modèles IA (services) par catégorie
- Définition des capacités globales par catégorie
- Association modèles-capacités avec multiplicateurs de coût
- Activation/désactivation des services, capacités et associations
- Gestion des prix par pays avec historique
- Configuration des disponibilités géographiques
- Paramétrage des métadonnées (features, limitations)
- Interface de gestion des relations many-to-many

#### 3.6.3 Outils de gestion

- **Historique des prix**: Traçabilité complète des modifications
- **Configuration système**: Paramètres globaux (points par dollar, pays supportés, etc.)
- **Gestion des promotions**: Création et suivi des campagnes
- **Monitoring**: Statistiques d'utilisation et performances

### 3.7 Fonctionnalités système

- **Internationalisation complète**: Support multilingue
- **Row Level Security (RLS)**: Sécurité au niveau base de données
- **API rate limiting**: Configuration flexible
- **Système de mise à jour**:
  - Mises à jour majeures (obligatoires)
  - Mises à jour mineures (facultatives)

## 4. Catalogue des services IA

### 4.1 Large Language Models (LLMs)
*Catégorie: llm*

**Modèles disponibles:**
- Claude Opus 4 (Anthropic)
- Claude Sonnet 4 (Anthropic)
- GPT-4 Turbo (OpenAI)
- GPT-4 (OpenAI)
- Grok (xAI)

**Capacités possibles pour chaque modèle:**
- Assistant Conversationnel (chat-assistant)
- Génération de Texte (text-generation)
- Génération de Code (code-generation)
- Analyse de Texte (text-analysis)
- Traduction Avancée (translation-llm)
- Raisonnement & Mathématiques (reasoning-math)
- Multimodal - Vision + Texte (multimodal-llm)
- LLMs Spécialisés (specialized-llm)

### 4.2 Génération vidéo
*Catégorie: video-generation*

**Modèles disponibles:**
- Google Veo
- MiniMax
- RunwayML Gen-3
- Pika Labs
- Stable Video Diffusion
- HeyGen
- Synthesia

**Capacités possibles:**
- Text-to-Video (text-to-video): Texte → Vidéo
- Image-to-Video (image-to-video): Image → Vidéo

### 4.3 Génération d'images
*Catégorie: image-generation*

- DALL-E 3 (OpenAI)
- Midjourney (via API)
- Stable Diffusion XL
- Adobe Firefly
- Flux.1 ⭐
- Ideogram AI (à évaluer)
- Leonardo AI (à évaluer)

### 4.4 Services audio
*Catégorie: audio-services*

**Modèles disponibles:**
- ElevenLabs
- Google Cloud TTS/STT
- Microsoft Azure TTS/STT
- Stable Audio

**Capacités possibles:**
- Text-to-Speech (text-to-speech): Texte → Audio
- Speech-to-Text (speech-to-text): Audio → Texte
- Génération musicale (music-generation): Texte → Musique

### 4.5 Assistance au développement
*Catégorie: dev-assistance*

- GitHub Copilot API
- Replit AI
- Codeium
- Tabnine
- Amazon CodeWhisperer
- Cursor AI
- MiniMax Agent

### 4.6 Services de traduction
*Catégorie: translation*

- DeepL API
- Google Translate API
- Meta NLLB (No Language Left Behind)
- ModernMT

### 4.7 Vision et analyse d'images
*Catégorie: vision-analysis*

- Google Vision API
- Amazon Rekognition
- Azure Computer Vision
- Clarifai
- Roboflow
- GPT-4V (Vision)
- Gemini Pro Vision

### 4.8 Recherche et RAG
*Catégorie: search-rag*

#### Bases de données vectorielles
- Pinecone
- Weaviate
- Qdrant
- ChromaDB

#### APIs de recherche
- Perplexity API
- You.com API

### 4.9 Services 3D et avatars
*Catégorie: 3d-avatars*

- Meshy AI (text-to-3D)
- Spline AI
- Kaedim3D
- Ready Player Me
- Synthesia (avatars vidéo)

### 4.10 Traitement de documents
*Catégorie: document-processing*

- Anthropic Claude (analyse de documents)
- Adobe PDF Services API
- DocuSign AI
- Nanonets (OCR + IA)

### 4.11 Services spécialisés
*Catégorie: specialized*

#### Marketing et rédaction
- Jasper AI
- Copy.ai
- Writesonic

#### Design
- Canva AI
- Figma AI

#### Analyse de données
- Julius AI
- Code Interpreter

#### Agents IA
- AutoGPT
- BabyAGI
- LangChain

## 5. Système de tarification et points

### 5.1 Mécanisme des points

- **Configuration système**: 100 points = 1 USD (configurable)
- **Recharge minimum**: 500 points (configurable)
- Chaque service consomme un nombre variable de points
- Affichage transparent du coût en points avant utilisation

### 5.2 Tarification par pays

- **Prix de base obligatoire** pour chaque service
- **Prix spécifiques par pays** (optionnels)
- **Fonction de calcul automatique**: `get_service_price_for_user()`
- **Contrainte de prix minimum**: Empêche de définir un prix inférieur au prix de base

### 5.3 Gestion financière (Interface admin)

#### Dashboard de rentabilité en temps réel

```
Modèle     | Pays | Coût API | Prix Client | Marge  | Utilisation
-----------|------|----------|-------------|--------|-------------
GPT-4      | US   | 0.03$/req| 300 points  | 40%    | 1,234 req/jour
GPT-4      | FR   | 0.03$/req| 350 points  | 45%    | 890 req/jour
Claude-3   | US   | 0.02$/req| 200 points  | 35%    | 2,100 req/jour
```

- Rapports de rentabilité exportables
- Alertes sur les marges faibles
- Historique complet des modifications de prix avec traçabilité

## 6. Internationalisation (i18n)

### 6.1 Architecture de traduction

- Code langue stocké dans le profil utilisateur (language_code)
- Fichiers de traduction JSON par langue
- Clés de traduction pour tous les textes
- Support des formats de date/heure/monnaie locaux
- Direction du texte (LTR/RTL) adaptable

### 6.2 Gestion des traductions

- Interface d'administration pour gérer les traductions
- Export/Import des fichiers de traduction
- Détection automatique de la langue préférée
- Fallback vers l'anglais si traduction manquante

## 7. Sécurité et permissions

### 7.1 Row Level Security (RLS)

- **Utilisateurs standards**:
  - Accès lecture/écriture à leur propre profil
  - Accès lecture seule à leur wallet
  - Visualisation des services actifs uniquement
  - Accès aux prix de leur pays uniquement
  - Consultation de leurs propres transactions et usage

- **Administrateurs** (is_admin = true):
  - Accès complet à toutes les tables
  - Gestion des services et catégories
  - Configuration des prix par pays
  - Accès aux vues de rentabilité
  - Gestion des promotions et configuration système

### 7.2 Fonctions sécurisées

- `deduct_wallet_points()`: SECURITY DEFINER pour gérer les transactions
- `get_service_price_for_user()`: SECURITY DEFINER pour le calcul des prix

## 8. Prochaines étapes

### 8.1 Phase 1 - MVP

1. **Structure de base et migration**
   - Appliquer la migration `service_subcategories` → `service_abilities` avec relation many-to-many
   - Implémenter la nouvelle architecture 3 niveaux avec table de liaison
   - Configurer l'authentification et les profils utilisateurs

2. **Système financier**
   - Développer le système de wallet et points
   - Implémenter le calcul de coût par association modèle-capacité
   - Intégrer les multiplicateurs de coût dans la tarification
   - Créer l'interface d'administration avec dashboard financier

3. **Gestion des services et capacités**
   - Interface de gestion des modèles par catégorie
   - Interface de définition des capacités globales
   - Système d'association many-to-many modèles-capacités
   - Gestion des multiplicateurs de coût par association
   - Intégrer 3-5 modèles LLM avec leurs capacités partagées

4. **Internationalisation**
   - Mettre en place l'infrastructure i18n
   - Interface utilisateur responsive

### 8.2 Phase 2 - Expansion

1. **Extension des services**
   - Ajouter progressivement les autres catégories (génération d'images, vidéo, audio)
   - Définir les capacités partagées pour chaque catégorie
   - Associer les nouveaux modèles aux capacités existantes et nouvelles
   - Configuration des multiplicateurs de coût par association

2. **Fonctionnalités avancées**
   - Implémenter le système de promotions
   - Développer les restrictions géographiques avancées
   - Interface de comparaison de modèles par capacité
   - Enrichir les traductions disponibles

3. **Optimisation**
   - Interface utilisateur avec navigation par capacités
   - Vue "Quels modèles supportent cette capacité?"
   - Outils de reporting financier par modèle et capacité
   - Analytics d'utilisation des associations modèle-capacité
   - Recommandations de modèles basées sur les capacités demandées

### 8.3 Phase 3 - Optimisation

1. Déployer des modèles open source
2. Développer des outils de paiement propriétaires
3. Optimiser les marges via l'analyse des données
4. Ajouter des fonctionnalités avancées (cache, batch processing)
5. Automatiser la gestion des prix dynamiques
6. Implémenter des algorithmes de recommandation

## 9. Considérations importantes

### 9.1 Défis techniques

- Gestion de la latence avec multiples APIs
- Standardisation des réponses des différents services
- Gestion des quotas et limites des APIs tierces
- Synchronisation des traductions entre plateformes
- Optimisation des requêtes avec les vues matérialisées

### 9.2 Aspects légaux et conformité

- RGPD et protection des données
- Licences d'utilisation des différents services
- Restrictions géographiques et conformité locale
- Transparence sur la tarification
- Audit trail pour les transactions financières

### 9.3 Modèle économique

- Structure de tarification en points avec conversion USD configurable
- Calcul automatique des marges bénéficiaires par pays
- Stratégie de prix compétitifs avec suivi en temps réel
- Gestion des promotions et réductions avec tracking
- Packages de points avec bonus volume
- Analyse de rentabilité par service et par région

### 9.4 Performance et scalabilité

- Indexation optimisée pour les requêtes fréquentes
- Utilisation de vues pour les calculs complexes
- Triggers pour maintenir la cohérence des données
- Politiques RLS efficaces pour la sécurité