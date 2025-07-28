# CLAUDE.md

Ce fichier fournit des directives à Claude Code (claude.ai/code) lors du travail sur le code de ce dépôt.

## Vue d'ensemble du projet

Il s'agit d'une application Vue.js 3 utilisant Vite comme outil de build. Elle fait partie d'une plateforme SaaS d'IA (epavillon2025) qui fournira un accès centralisé à plusieurs services d'IA via une interface unifiée avec un système de points.

**IMPORTANT**: Pour comprendre le projet en détail, consulter le cahier des charges complet dans `bank/conception-saas-ia-centralise-finale.md`. Pour comprendre le modèle de données, consulter le schéma de base de données dans `bank/schema_updated_Version2.sql`.

## Technologies clés

- **Frontend**: Vue.js 3 avec Composition API
- **Backend**: Supabase (PostgreSQL avec Row Level Security)
- **Outil de build**: Vite
- **Routage**: Vue Router 4 
- **Gestion d'état**: Pinia
- **Styles**: Tailwind CSS 4 avec support mode sombre/clair
- **Internationalisation**: Vue i18n (Français/Anglais)
- **Icônes**: Font Awesome
- **Tests**: Vitest (tests unitaires), Playwright (tests e2e)
- **Outils de dev**: Plugin Vue DevTools activé

## Commandes de développement

### Commandes essentielles
```bash
# Installer les dépendances
npm install

# Démarrer le serveur de développement (http://localhost:5173)
npm run dev

# Build pour la production
npm run build

# Prévisualiser le build de production (http://localhost:4173)
npm run preview

# Exécuter les tests unitaires avec Vitest
npm run test:unit

# Exécuter les tests e2e avec Playwright
npm run test:e2e

# Installer les navigateurs Playwright (première configuration)
npx playwright install
```

### Commandes de test
```bash
# Exécuter les tests e2e sur un navigateur spécifique
npm run test:e2e -- --project=chromium

# Exécuter un fichier de test e2e spécifique
npm run test:e2e -- tests/example.spec.ts

# Exécuter les tests e2e en mode debug
npm run test:e2e -- --debug
```

## Structure du projet

### Architecture principale
- **Point d'entrée**: `src/main.js` - Initialise l'app Vue avec Pinia, router, i18n, et Font Awesome
- **Composant racine**: `src/App.vue` - Contient l'en-tête responsive avec navigation, toggle de thème, sélecteur de langue, et outlet du router
- **Routage**: `src/router/index.js` - Définit les routes de l'app avec lazy loading pour la page About
- **Gestion d'état**: `src/stores/` - Stores Pinia (counter, theme, locale)

### Répertoires clés
- `src/components/` - Composants Vue réutilisables incluant le sous-dossier `ui/` pour les composants UI (ThemeToggle, LanguageSelector)
- `src/views/` - Composants au niveau page, inclut le sous-dossier `admin/`
- `src/assets/` - Assets statiques incluant la configuration Tailwind CSS avec support du mode sombre
- `src/lib/` - Bibliothèques utilitaires
- `src/utils/` - Fonctions utilitaires
- `src/plugins/` - Plugins Vue (i18n, configuration Font Awesome)
- `src/stores/` - Stores Pinia (theme.js pour mode sombre/clair, locale.js pour gestion des langues, counter.js)
- `src/locales/` - Fichiers d'internationalisation (en.json, fr.json)
- `e2e/` - Tests end-to-end Playwright
- `bank/` - Documentation du projet et schéma de base de données

### Fichiers de configuration
- `vite.config.js` - Configuration Vite avec plugin Vue et alias @ pour src/
- `vitest.config.js` - Configuration des tests unitaires utilisant l'environnement jsdom
- `playwright.config.js` - Configuration des tests e2e pour tests multi-navigateurs
- `tailwind.config.js` - Configuration Tailwind CSS 4 avec couleurs primaires personnalisées
- `src/assets/main.css` - CSS principal avec imports Tailwind et variant personnalisé mode sombre

## Notes de développement

### Alias de chemins
- `@` est un alias vers le répertoire `src/`

### Implémentation mode sombre/clair
- Utilise la variante personnalisée Tailwind CSS 4: `@custom-variant dark (&:where(.dark, .dark *))`
- Gestion du thème via store Pinia (`src/stores/theme.js`)
- Persiste la préférence de thème dans localStorage
- Respecte les préférences système par défaut
- Composant toggle de thème dans l'en-tête (`src/components/ui/ThemeToggle.vue`)
- **IMPORTANT**: Toujours utiliser les classes `dark:` pour le style en mode sombre dans tous les composants

### Internationalisation (i18n)
- Supporte le français (`fr`) et l'anglais (`en`) 
- Géré via Vue i18n et store Pinia (`src/stores/locale.js`)
- Fichiers de langue dans `src/locales/` (en.json, fr.json)
- Persiste la préférence de langue dans localStorage
- Composant sélecteur de langue dans l'en-tête (`src/components/ui/LanguageSelector.vue`)
- **IMPORTANT**: Toujours utiliser `$t('key')` pour tout contenu texte dans les composants

### Font Awesome
- Configuré globalement via `src/plugins/fontawesome.js`
- Icônes disponibles: sun, moon, globe, chevron-up, chevron-down, home, info-circle
- Utilisation: `<font-awesome-icon icon="icon-name" />`

### Directives de développement de composants
- **Toujours inclure le style mode sombre**: Utiliser les variantes `dark:` pour toutes les couleurs de fond, texte et bordures
- **Toujours utiliser i18n**: Remplacer le texte codé en dur par `$t('translation.key')`
- **Suivre le design responsive**: Utiliser les classes responsive Tailwind
- **Maintenir la cohérence**: Suivre les modèles existants dans `src/components/ui/`

### Configuration des tests
- Les tests unitaires utilisent Vitest avec environnement jsdom
- Les tests e2e utilisent Playwright avec démarrage automatique du serveur de dev
- Les tests e2e s'exécutent sur Chromium, Firefox, et WebKit
- Configuration CI incluse pour les deux suites de tests

### APIs de services d'IA
- **LLMs**: OpenRouter API (https://openrouter.ai/docs/api-reference/overview)
- **Autres modèles**: Fal API (https://docs.fal.ai/)

### Architecture future
Basé sur la documentation du projet, ceci est planifié pour faire partie d'une plateforme SaaS d'IA plus large qui:
- Utilisera Supabase pour le backend (PostgreSQL avec RLS)
- Intégrera plusieurs APIs de services d'IA (OpenRouter, fal.ai)
- Inclura une app mobile Flutter
- Implémentera un système de paiement basé sur les points
- Supportera le déploiement multi-pays

### État actuel
Le projet est en phase de développement précoce avec l'architecture Vue 3 et un composant AppSideBar implémenté. Le schéma de base de données et l'architecture sont définis pour l'intégration backend Supabase. Ceci évoluera vers une plateforme complète de services d'IA avec facturation basée sur les points et intégration multi-services.

### Intégration backend
- **Base de données**: PostgreSQL avec Supabase
- **Authentification**: Supabase Auth avec OAuth Google/Apple et email/mot de passe
- **Temps réel**: Abonnements temps réel Supabase pour mises à jour en direct
- **Row Level Security**: Implémenté pour accès sécurisé aux données multi-locataires
- **API**: Client Supabase pour opérations de base de données et fonctionnalités temps réel