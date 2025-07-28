# Fonctionnalités de la Page d'Administration

Basé sur la documentation complète du projet, voici toutes les fonctionnalités que devrait avoir la page d'administration :

## 1. 📊 Dashboard de Rentabilité

### 1.1 Vue d'ensemble financière
1. **Métriques en temps réel** avec vue `service_profitability` :
   - Coût API par service (prix d'achat)
   - Prix facturé au client (prix de vente)
   - Marge bénéficiaire calculée automatiquement
   - Statistiques d'utilisation par modèle et par pays
   - Analyse sur 30 jours glissants

### 1.2 Rapports financiers
2. Rapports de rentabilité exportables
3. Alertes sur les marges faibles
4. Calculs automatiques de profit par service et région

## 2. 🛠️ Gestion des Services IA

### 2.1 Gestion des catégories
5. CRUD complet des catégories (`service_categories`)
6. Configuration des icônes et ordre d'affichage
7. Activation/désactivation des catégories

### 2.2 Gestion des sous-catégories
8. CRUD des sous-catégories (`service_subcategories`)
9. Configuration des métadonnées de transformation (from_type → to_type)
10. Gestion des icônes spécifiques par type

### 2.3 Gestion des services
11. CRUD complet des services IA (`ai_services`)
12. Configuration des providers et endpoints API
13. Gestion des métadonnées (features, limitations)
14. Paramétrage des configurations JSONB
15. Badge "Nouveau" avec date de fin configurable
16. Support des promotions et réductions

## 3. 💰 Gestion Tarifaire

### 3.1 Prix par pays
17. Configuration des prix spécifiques par pays (`service_pricing_by_country`)
18. Prix de base obligatoire avec contrainte de prix minimum
19. Interface pour définir les prix par région
20. Historique complet des modifications de prix (`price_history`)

### 3.2 Disponibilité géographique
21. Gestion des restrictions par pays (`service_availability`)
22. Configuration des pays supportés
23. Activation/désactivation des services par région

## 4. 🎯 Système de Promotions

### 4.1 Gestion des promotions
24. CRUD des promotions et codes promo (`promotions`)
25. Types de réductions (pourcentage, points fixes)
26. Conditions d'utilisation (achat minimum, nombre max d'usages)
27. Restrictions par service(s) et pays
28. Suivi des utilisations (`promotion_usage`)

## 5. 👥 Gestion des Utilisateurs

### 5.1 Administration des comptes
29. Vue d'ensemble des profils utilisateurs (`profiles`)
30. Gestion des statuts admin (`is_admin`)
31. Consultation des wallets utilisateurs (`wallets`)
32. Historique des transactions (`wallet_transactions`)

### 5.2 Monitoring d'usage
33. Consultation de l'usage des services (`service_usage`)
34. Statistiques d'utilisation par utilisateur
35. Tracking de la consommation de points

## 6. ⚙️ Configuration Système

### 6.1 Paramètres globaux
36. Configuration système via `system_config` :
    - Points par dollar (conversion USD)
    - Recharge minimum du wallet
    - Durée d'affichage "nouveau service"
    - Rate limiting API
    - Liste des pays supportés

### 6.2 Outils de gestion
37. Historique des prix avec traçabilité complète
38. Configuration des métadonnées services
39. Paramètres de disponibilité géographique

## 7. 📈 Monitoring et Statistiques

### 7.1 Analytics d'utilisation
40. Statistiques d'utilisation par modèle
41. Performance des services par pays
42. Métriques de rentabilité en temps réel
43. Suivi des tendances d'usage

### 7.2 Rapports d'activité
44. Rapports exportables
45. Analyse des performances financières
46. Tracking des promotions et leur efficacité

## 8. 🔧 Outils d'Administration

### 8.1 Interface de gestion
47. Interface web uniquement (pas mobile)
48. Navigation entre les différentes sections
49. Tableaux de données avec filtres et tri
50. Formulaires de configuration avancés

### 8.2 Sécurité et permissions
51. Accès restreint aux administrateurs (`is_admin = true`)
52. Row Level Security (RLS) pour toutes les opérations
53. Audit trail pour les modifications importantes

## 🗂️ Tables de Base de Données Concernées

### Tables principales
- `profiles` - Gestion des utilisateurs et statuts admin
- `wallets` - Gestion des portefeuilles utilisateurs
- `wallet_transactions` - Historique des transactions

### Services IA
- `service_categories` - Catégories de services
- `service_subcategories` - Sous-catégories avec métadonnées
- `ai_services` - Services IA disponibles
- `service_pricing_by_country` - Prix par pays
- `service_availability` - Disponibilité géographique
- `service_usage` - Journal d'utilisation

### Promotions et configuration
- `promotions` - Codes promo et réductions
- `promotion_usage` - Suivi des utilisations
- `price_history` - Historique des prix
- `system_config` - Configuration système

### Vues pour l'administration
- `service_profitability` - Métriques de rentabilité
- `service_effective_pricing` - Prix effectifs par pays