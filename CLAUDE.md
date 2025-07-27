# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Vue.js 3 application using Vite as the build tool. It's part of an AI SaaS platform (epavillon2025) that will provide centralized access to multiple AI services through a unified interface with a points-based system.

## Key Technologies

- **Frontend**: Vue.js 3 with Composition API
- **Build Tool**: Vite
- **Routing**: Vue Router 4 
- **State Management**: Pinia
- **Styling**: Tailwind CSS 4 with Dark/Light mode support
- **Internationalization**: Vue i18n (French/English)
- **Icons**: Font Awesome
- **Testing**: Vitest (unit tests), Playwright (e2e tests)
- **Dev Tools**: Vue DevTools plugin enabled

## Development Commands

### Essential Commands
```bash
# Install dependencies
npm install

# Start development server (http://localhost:5173)
npm run dev

# Build for production
npm run build

# Preview production build (http://localhost:4173)
npm run preview

# Run unit tests with Vitest
npm run test:unit

# Run e2e tests with Playwright
npm run test:e2e

# Install Playwright browsers (first time setup)
npx playwright install
```

### Testing Commands
```bash
# Run e2e tests on specific browser
npm run test:e2e -- --project=chromium

# Run specific e2e test file
npm run test:e2e -- tests/example.spec.ts

# Run e2e tests in debug mode
npm run test:e2e -- --debug
```

## Project Structure

### Core Architecture
- **Entry Point**: `src/main.js` - Initializes Vue app with Pinia, router, i18n, and Font Awesome
- **Root Component**: `src/App.vue` - Contains responsive header with navigation, theme toggle, language selector, and router outlet
- **Routing**: `src/router/index.js` - Defines app routes with lazy loading for About page
- **State Management**: `src/stores/` - Pinia stores (counter, theme, locale)

### Key Directories
- `src/components/` - Reusable Vue components including `ui/` subfolder for UI components (ThemeToggle, LanguageSelector)
- `src/views/` - Page-level components, includes `admin/` subfolder
- `src/assets/` - Static assets including Tailwind CSS configuration with dark mode support
- `src/lib/` - Utility libraries
- `src/utils/` - Utility functions
- `src/plugins/` - Vue plugins (i18n, Font Awesome configuration)
- `src/stores/` - Pinia stores (theme.js for dark/light mode, locale.js for language management, counter.js)
- `src/locales/` - Internationalization files (en.json, fr.json)
- `e2e/` - Playwright end-to-end tests
- `bank/` - Project documentation and database schema

### Configuration Files
- `vite.config.js` - Vite configuration with Vue plugin and @ alias for src/
- `vitest.config.js` - Unit test configuration using jsdom environment
- `playwright.config.js` - E2e test configuration for multi-browser testing
- `tailwind.config.js` - Tailwind CSS 4 configuration with custom primary colors
- `src/assets/main.css` - Main CSS with Tailwind imports and dark mode custom variant

## Development Notes

### Path Aliases
- `@` is aliased to `src/` directory

### Dark/Light Mode Implementation
- Uses Tailwind CSS 4 custom variant: `@custom-variant dark (&:where(.dark, .dark *))`
- Theme management via Pinia store (`src/stores/theme.js`)
- Persists theme preference in localStorage
- Respects system preferences by default
- Theme toggle component in header (`src/components/ui/ThemeToggle.vue`)
- **IMPORTANT**: Always use `dark:` classes for dark mode styling in all components

### Internationalization (i18n)
- Supports French (`fr`) and English (`en`) 
- Managed via Vue i18n and Pinia store (`src/stores/locale.js`)
- Language files in `src/locales/` (en.json, fr.json)
- Persists language preference in localStorage
- Language selector component in header (`src/components/ui/LanguageSelector.vue`)
- **IMPORTANT**: Always use `$t('key')` for all text content in components

### Font Awesome
- Configured globally via `src/plugins/fontawesome.js`
- Available icons: sun, moon, globe, chevron-up, chevron-down, home, info-circle
- Use as: `<font-awesome-icon icon="icon-name" />`

### Component Development Guidelines
- **Always include dark mode styling**: Use `dark:` variants for all background, text, and border colors
- **Always use i18n**: Replace hardcoded text with `$t('translation.key')`
- **Follow responsive design**: Use Tailwind responsive classes
- **Maintain consistency**: Follow existing patterns in `src/components/ui/`

### Testing Setup
- Unit tests use Vitest with jsdom environment
- E2e tests use Playwright with automatic dev server startup
- E2e tests run on Chromium, Firefox, and WebKit
- CI configuration included for both test suites

### Future Architecture
Based on project documentation, this is planned to be part of a larger AI SaaS platform that will:
- Use Supabase for backend (PostgreSQL with RLS)
- Integrate multiple AI service APIs (OpenRouter, fal.ai)
- Include Flutter mobile app
- Implement points-based payment system
- Support multi-country deployment

### Current State
The project appears to be in early development stage with standard Vue 3 starter template structure. The banking documentation suggests this will evolve into a comprehensive AI services platform.