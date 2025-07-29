<template>
  <div class="space-y-6">
    <!-- En-tête -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <h2 class="text-xl font-semibold text-gray-900 dark:text-white">
        {{ $t('admin.config.title') }}
      </h2>
    </div>

    <!-- Paramètres globaux -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-6">
        {{ $t('admin.config.globalSettings') }}
      </h3>
      
      <form @submit.prevent="saveConfiguration" class="space-y-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Points par dollar -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              {{ $t('admin.config.pointsPerDollar') }}
            </label>
            <input
              v-model.number="config.points_per_dollar"
              type="number"
              min="1"
              step="1"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            >
          </div>

          <!-- Recharge minimum -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              {{ $t('admin.config.minWalletRecharge') }} (points)
            </label>
            <input
              v-model.number="config.min_wallet_recharge"
              type="number"
              min="1"
              step="1"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            >
          </div>

          <!-- Durée badge nouveau -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              {{ $t('admin.config.newServiceDuration') }} ({{ $t('admin.config.days') }})
            </label>
            <input
              v-model.number="config.new_service_days"
              type="number"
              min="1"
              max="365"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            >
          </div>

          <!-- Rate limiting -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              {{ $t('admin.config.rateLimiting') }} ({{ $t('admin.config.requestsPerMinute') }})
            </label>
            <input
              v-model.number="config.api_rate_limit.requests_per_minute"
              type="number"
              min="1"
              max="1000"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            >
          </div>
        </div>

        <!-- Mode maintenance -->
        <div class="space-y-4">
          <div class="flex items-center">
            <input
              v-model="config.maintenance_mode"
              type="checkbox"
              id="maintenance-mode"
              class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
            >
            <label for="maintenance-mode" class="ml-2 text-sm font-medium text-gray-700 dark:text-gray-300">
              {{ $t('admin.config.maintenanceMode') }}
            </label>
          </div>

          <div v-if="config.maintenance_mode">
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              {{ $t('admin.config.maintenanceMessage') }}
            </label>
            <textarea
              v-model="config.maintenance_message"
              rows="3"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            ></textarea>
          </div>
        </div>

        <!-- Pays supportés -->
        <div>
          <div class="flex items-center justify-between mb-4">
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
              {{ $t('admin.config.supportedCountries') }}
            </label>
            <div class="flex items-center space-x-4">
              <button
                type="button"
                @click="selectAllCountries"
                class="text-sm text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300"
              >
                Tout sélectionner
              </button>
              <button
                type="button"
                @click="deselectAllCountries"
                class="text-sm text-red-600 dark:text-red-400 hover:text-red-800 dark:hover:text-red-300"
              >
                Tout désélectionner
              </button>
            </div>
          </div>

          <!-- Barre de recherche et filtres -->
          <div class="mb-4 space-y-3">
            <!-- Recherche -->
            <div class="relative">
              <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <font-awesome-icon icon="search" class="h-4 w-4 text-gray-400" />
              </div>
              <input
                v-model="countrySearch"
                type="text"
                placeholder="Rechercher un pays (nom ou code)..."
                class="block w-full pl-10 pr-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              >
            </div>

            <!-- Filtres par statut -->
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-1">
                <button
                  type="button"
                  @click="countryFilter = 'all'"
                  :class="[
                    'px-3 py-1.5 text-sm font-medium rounded-md transition-colors',
                    countryFilter === 'all'
                      ? 'bg-blue-100 text-blue-700 dark:bg-blue-900 dark:text-blue-300'
                      : 'bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
                  ]"
                >
                  Tous ({{ availableCountries.length }})
                </button>
                <button
                  type="button"
                  @click="countryFilter = 'active'"
                  :class="[
                    'px-3 py-1.5 text-sm font-medium rounded-md transition-colors',
                    countryFilter === 'active'
                      ? 'bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-300'
                      : 'bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
                  ]"
                >
                  Actifs ({{ config.supported_countries.length }})
                </button>
                <button
                  type="button"
                  @click="countryFilter = 'inactive'"
                  :class="[
                    'px-3 py-1.5 text-sm font-medium rounded-md transition-colors',
                    countryFilter === 'inactive'
                      ? 'bg-red-100 text-red-700 dark:bg-red-900 dark:text-red-300'
                      : 'bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600'
                  ]"
                >
                  Inactifs ({{ availableCountries.length - config.supported_countries.length }})
                </button>
              </div>
              
              <!-- Bouton de réinitialisation -->
              <button
                v-if="countrySearch || countryFilter !== 'all'"
                type="button"
                @click="resetCountryFilters"
                class="text-sm text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300 transition-colors"
                title="Réinitialiser les filtres"
              >
                <font-awesome-icon icon="times" class="mr-1" />
                Réinitialiser
              </button>
            </div>
          </div>
          
          <!-- Compteur de pays sélectionnés -->
          <div class="mb-4 p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
            <div class="flex items-center justify-between">
              <p class="text-sm text-blue-700 dark:text-blue-300">
                <span class="font-medium">{{ config.supported_countries.length }}</span> pays sélectionnés sur {{ availableCountries.length }}
              </p>
              <p class="text-xs text-blue-600 dark:text-blue-400" v-if="filteredCountries.length !== availableCountries.length">
                {{ filteredCountries.length }} affiché(s)
              </p>
            </div>
          </div>

          <!-- Message si aucun résultat -->
          <div v-if="filteredCountries.length === 0" class="text-center py-8 text-gray-500 dark:text-gray-400">
            <font-awesome-icon icon="search" class="h-8 w-8 mb-2" />
            <p>Aucun pays trouvé pour cette recherche</p>
          </div>

          <!-- Grille des pays avec boutons switch -->
          <div v-else class="max-h-96 overflow-y-auto border border-gray-200 dark:border-gray-600 rounded-lg">
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-0">
              <div 
                v-for="country in filteredCountries" 
                :key="country.code" 
                class="flex items-center justify-between p-3 border-b border-gray-100 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800/50 transition-colors"
              >
                <div class="flex items-center space-x-3">
                  <span class="text-lg">{{ country.flag }}</span>
                  <div>
                    <div class="text-sm font-medium text-gray-900 dark:text-white">
                      {{ country.name }}
                    </div>
                    <div class="text-xs text-gray-500 dark:text-gray-400">
                      {{ country.code }}
                    </div>
                  </div>
                </div>
                
                <!-- Switch Toggle -->
                <button
                  type="button"
                  @click="toggleCountry(country.code)"
                  :class="[
                    'relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-blue-600 focus:ring-offset-2',
                    isCountrySupported(country.code) 
                      ? 'bg-blue-600' 
                      : 'bg-gray-200 dark:bg-gray-700'
                  ]"
                  role="switch"
                  :aria-checked="isCountrySupported(country.code)"
                >
                  <span class="sr-only">Activer {{ country.name }}</span>
                  <span
                    :class="[
                      'pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out',
                      isCountrySupported(country.code) 
                        ? 'translate-x-5' 
                        : 'translate-x-0'
                    ]"
                  ></span>
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Boutons d'action -->
        <div class="flex items-center justify-between">
          <button
            type="button"
            @click="resetToDefaults"
            class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
          >
            {{ $t('admin.config.resetToDefaults') }}
          </button>
          
          <div class="space-x-3">
            <button
              type="button"
              @click="loadConfiguration"
              :disabled="adminStore.isLoading"
              class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
            >
              <font-awesome-icon icon="sync" :class="{ 'animate-spin': adminStore.isLoading }" class="mr-2" />
              {{ $t('admin.common.refresh') }}
            </button>
            
            <button
              type="submit"
              :disabled="adminStore.isLoading"
              class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors disabled:opacity-50"
            >
              {{ adminStore.isLoading ? $t('admin.common.loading') : $t('admin.config.updateConfig') }}
            </button>
          </div>
        </div>
      </form>
    </div>

    <!-- Configuration API -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-6">
        {{ $t('admin.config.apiSettings') }}
      </h3>
      
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Timeout API (secondes)
          </label>
          <input
            v-model.number="config.api_timeout_seconds"
            type="number"
            min="1"
            max="300"
            class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
          >
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            Retry maximum
          </label>
          <input
            v-model.number="config.max_retries"
            type="number"
            min="0"
            max="10"
            class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
          >
        </div>
      </div>
    </div>

    <!-- Paramètres de sauvegarde -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-6">
        {{ $t('admin.config.backupSettings') }}
      </h3>
      
      <div class="space-y-4">
        <div class="flex items-center justify-between p-4 border border-gray-200 dark:border-gray-600 rounded-lg">
          <div>
            <h4 class="text-sm font-medium text-gray-900 dark:text-white">Sauvegarde automatique</h4>
            <p class="text-sm text-gray-500 dark:text-gray-400">Sauvegardes quotidiennes des données critiques</p>
          </div>
          <div class="flex items-center">
            <input
              v-model="config.auto_backup_enabled"
              type="checkbox"
              class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
            >
          </div>
        </div>

        <div v-if="config.auto_backup_enabled" class="ml-4 space-y-2">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
              Rétention (jours)
            </label>
            <input
              v-model.number="config.backup_retention_days"
              type="number"
              min="1"
              max="365"
              class="mt-1 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            >
          </div>
        </div>

        <div class="flex space-x-3">
          <button
            type="button"
            @click="createManualBackup"
            class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors"
          >
            <font-awesome-icon icon="download" class="mr-2" />
            Créer une sauvegarde manuelle
          </button>
          
          <button
            type="button"
            @click="downloadConfiguration"
            class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
          >
            <font-awesome-icon icon="download" class="mr-2" />
            Exporter la configuration
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAdminStore } from '@/stores/admin'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const adminStore = useAdminStore()

// Configuration par défaut basée sur le schéma de la base de données
const defaultConfig = {
  points_per_dollar: 100,
  min_wallet_recharge: 500,
  new_service_days: 30,
  api_rate_limit: { requests_per_minute: 60 },
  supported_countries: ["US", "CI", "FR", "CA", "GB", "DE", "JP", "BR", "IN"],
  // Champs additionnels pour l'interface admin
  maintenance_mode: false,
  maintenance_message: 'Maintenance en cours. Veuillez réessayer plus tard.',
  api_timeout_seconds: 30,
  max_retries: 3,
  auto_backup_enabled: true,
  backup_retention_days: 30
}

// État local
const config = ref({ ...defaultConfig })

// État pour les filtres des pays
const countrySearch = ref('')
const countryFilter = ref('all') // 'all', 'active', 'inactive'

// Liste complète des pays avec drapeaux
const availableCountries = ref([
  { code: 'AD', name: 'Andorre', flag: '🇦🇩' },
  { code: 'AE', name: 'Émirats arabes unis', flag: '🇦🇪' },
  { code: 'AF', name: 'Afghanistan', flag: '🇦🇫' },
  { code: 'AG', name: 'Antigua-et-Barbuda', flag: '🇦🇬' },
  { code: 'AI', name: 'Anguilla', flag: '🇦🇮' },
  { code: 'AL', name: 'Albanie', flag: '🇦🇱' },
  { code: 'AM', name: 'Arménie', flag: '🇦🇲' },
  { code: 'AO', name: 'Angola', flag: '🇦🇴' },
  { code: 'AQ', name: 'Antarctique', flag: '🇦🇶' },
  { code: 'AR', name: 'Argentine', flag: '🇦🇷' },
  { code: 'AS', name: 'Samoa américaines', flag: '🇦🇸' },
  { code: 'AT', name: 'Autriche', flag: '🇦🇹' },
  { code: 'AU', name: 'Australie', flag: '🇦🇺' },
  { code: 'AW', name: 'Aruba', flag: '🇦🇼' },
  { code: 'AX', name: 'Îles Åland', flag: '🇦🇽' },
  { code: 'AZ', name: 'Azerbaïdjan', flag: '🇦🇿' },
  { code: 'BA', name: 'Bosnie-Herzégovine', flag: '🇧🇦' },
  { code: 'BB', name: 'Barbade', flag: '🇧🇧' },
  { code: 'BD', name: 'Bangladesh', flag: '🇧🇩' },
  { code: 'BE', name: 'Belgique', flag: '🇧🇪' },
  { code: 'BF', name: 'Burkina Faso', flag: '🇧🇫' },
  { code: 'BG', name: 'Bulgarie', flag: '🇧🇬' },
  { code: 'BH', name: 'Bahreïn', flag: '🇧🇭' },
  { code: 'BI', name: 'Burundi', flag: '🇧🇮' },
  { code: 'BJ', name: 'Bénin', flag: '🇧🇯' },
  { code: 'BL', name: 'Saint-Barthélemy', flag: '🇧🇱' },
  { code: 'BM', name: 'Bermudes', flag: '🇧🇲' },
  { code: 'BN', name: 'Brunei', flag: '🇧🇳' },
  { code: 'BO', name: 'Bolivie', flag: '🇧🇴' },
  { code: 'BQ', name: 'Bonaire', flag: '🇧🇶' },
  { code: 'BR', name: 'Brésil', flag: '🇧🇷' },
  { code: 'BS', name: 'Bahamas', flag: '🇧🇸' },
  { code: 'BT', name: 'Bhoutan', flag: '🇧🇹' },
  { code: 'BV', name: 'Île Bouvet', flag: '🇧🇻' },
  { code: 'BW', name: 'Botswana', flag: '🇧🇼' },
  { code: 'BY', name: 'Biélorussie', flag: '🇧🇾' },
  { code: 'BZ', name: 'Belize', flag: '🇧🇿' },
  { code: 'CA', name: 'Canada', flag: '🇨🇦' },
  { code: 'CC', name: 'Îles Cocos', flag: '🇨🇨' },
  { code: 'CD', name: 'République démocratique du Congo', flag: '🇨🇩' },
  { code: 'CF', name: 'République centrafricaine', flag: '🇨🇫' },
  { code: 'CG', name: 'République du Congo', flag: '🇨🇬' },
  { code: 'CH', name: 'Suisse', flag: '🇨🇭' },
  { code: 'CI', name: 'Côte d\'Ivoire', flag: '🇨🇮' },
  { code: 'CK', name: 'Îles Cook', flag: '🇨🇰' },
  { code: 'CL', name: 'Chili', flag: '🇨🇱' },
  { code: 'CM', name: 'Cameroun', flag: '🇨🇲' },
  { code: 'CN', name: 'Chine', flag: '🇨🇳' },
  { code: 'CO', name: 'Colombie', flag: '🇨🇴' },
  { code: 'CR', name: 'Costa Rica', flag: '🇨🇷' },
  { code: 'CU', name: 'Cuba', flag: '🇨🇺' },
  { code: 'CV', name: 'Cap-Vert', flag: '🇨🇻' },
  { code: 'CW', name: 'Curaçao', flag: '🇨🇼' },
  { code: 'CX', name: 'Île Christmas', flag: '🇨🇽' },
  { code: 'CY', name: 'Chypre', flag: '🇨🇾' },
  { code: 'CZ', name: 'République tchèque', flag: '🇨🇿' },
  { code: 'DE', name: 'Allemagne', flag: '🇩🇪' },
  { code: 'DJ', name: 'Djibouti', flag: '🇩🇯' },
  { code: 'DK', name: 'Danemark', flag: '🇩🇰' },
  { code: 'DM', name: 'Dominique', flag: '🇩🇲' },
  { code: 'DO', name: 'République dominicaine', flag: '🇩🇴' },
  { code: 'DZ', name: 'Algérie', flag: '🇩🇿' },
  { code: 'EC', name: 'Équateur', flag: '🇪🇨' },
  { code: 'EE', name: 'Estonie', flag: '🇪🇪' },
  { code: 'EG', name: 'Égypte', flag: '🇪🇬' },
  { code: 'EH', name: 'Sahara occidental', flag: '🇪🇭' },
  { code: 'ER', name: 'Érythrée', flag: '🇪🇷' },
  { code: 'ES', name: 'Espagne', flag: '🇪🇸' },
  { code: 'ET', name: 'Éthiopie', flag: '🇪🇹' },
  { code: 'FI', name: 'Finlande', flag: '🇫🇮' },
  { code: 'FJ', name: 'Fidji', flag: '🇫🇯' },
  { code: 'FK', name: 'Îles Malouines', flag: '🇫🇰' },
  { code: 'FM', name: 'Micronésie', flag: '🇫🇲' },
  { code: 'FO', name: 'Îles Féroé', flag: '🇫🇴' },
  { code: 'FR', name: 'France', flag: '🇫🇷' },
  { code: 'GA', name: 'Gabon', flag: '🇬🇦' },
  { code: 'GB', name: 'Royaume-Uni', flag: '🇬🇧' },
  { code: 'GD', name: 'Grenade', flag: '🇬🇩' },
  { code: 'GE', name: 'Géorgie', flag: '🇬🇪' },
  { code: 'GF', name: 'Guyane française', flag: '🇬🇫' },
  { code: 'GG', name: 'Guernesey', flag: '🇬🇬' },
  { code: 'GH', name: 'Ghana', flag: '🇬🇭' },
  { code: 'GI', name: 'Gibraltar', flag: '🇬🇮' },
  { code: 'GL', name: 'Groenland', flag: '🇬🇱' },
  { code: 'GM', name: 'Gambie', flag: '🇬🇲' },
  { code: 'GN', name: 'Guinée', flag: '🇬🇳' },
  { code: 'GP', name: 'Guadeloupe', flag: '🇬🇵' },
  { code: 'GQ', name: 'Guinée équatoriale', flag: '🇬🇶' },
  { code: 'GR', name: 'Grèce', flag: '🇬🇷' },
  { code: 'GS', name: 'Géorgie du Sud', flag: '🇬🇸' },
  { code: 'GT', name: 'Guatemala', flag: '🇬🇹' },
  { code: 'GU', name: 'Guam', flag: '🇬🇺' },
  { code: 'GW', name: 'Guinée-Bissau', flag: '🇬🇼' },
  { code: 'GY', name: 'Guyana', flag: '🇬🇾' },
  { code: 'HK', name: 'Hong Kong', flag: '🇭🇰' },
  { code: 'HM', name: 'Îles Heard-et-MacDonald', flag: '🇭🇲' },
  { code: 'HN', name: 'Honduras', flag: '🇭🇳' },
  { code: 'HR', name: 'Croatie', flag: '🇭🇷' },
  { code: 'HT', name: 'Haïti', flag: '🇭🇹' },
  { code: 'HU', name: 'Hongrie', flag: '🇭🇺' },
  { code: 'ID', name: 'Indonésie', flag: '🇮🇩' },
  { code: 'IE', name: 'Irlande', flag: '🇮🇪' },
  { code: 'IL', name: 'Israël', flag: '🇮🇱' },
  { code: 'IM', name: 'Île de Man', flag: '🇮🇲' },
  { code: 'IN', name: 'Inde', flag: '🇮🇳' },
  { code: 'IO', name: 'Territoire britannique de l\'océan Indien', flag: '🇮🇴' },
  { code: 'IQ', name: 'Irak', flag: '🇮🇶' },
  { code: 'IR', name: 'Iran', flag: '🇮🇷' },
  { code: 'IS', name: 'Islande', flag: '🇮🇸' },
  { code: 'IT', name: 'Italie', flag: '🇮🇹' },
  { code: 'JE', name: 'Jersey', flag: '🇯🇪' },
  { code: 'JM', name: 'Jamaïque', flag: '🇯🇲' },
  { code: 'JO', name: 'Jordanie', flag: '🇯🇴' },
  { code: 'JP', name: 'Japon', flag: '🇯🇵' },
  { code: 'KE', name: 'Kenya', flag: '🇰🇪' },
  { code: 'KG', name: 'Kirghizistan', flag: '🇰🇬' },
  { code: 'KH', name: 'Cambodge', flag: '🇰🇭' },
  { code: 'KI', name: 'Kiribati', flag: '🇰🇮' },
  { code: 'KM', name: 'Comores', flag: '🇰🇲' },
  { code: 'KN', name: 'Saint-Christophe-et-Niévès', flag: '🇰🇳' },
  { code: 'KP', name: 'Corée du Nord', flag: '🇰🇵' },
  { code: 'KR', name: 'Corée du Sud', flag: '🇰🇷' },
  { code: 'KW', name: 'Koweït', flag: '🇰🇼' },
  { code: 'KY', name: 'Îles Caïmans', flag: '🇰🇾' },
  { code: 'KZ', name: 'Kazakhstan', flag: '🇰🇿' },
  { code: 'LA', name: 'Laos', flag: '🇱🇦' },
  { code: 'LB', name: 'Liban', flag: '🇱🇧' },
  { code: 'LC', name: 'Sainte-Lucie', flag: '🇱🇨' },
  { code: 'LI', name: 'Liechtenstein', flag: '🇱🇮' },
  { code: 'LK', name: 'Sri Lanka', flag: '🇱🇰' },
  { code: 'LR', name: 'Liberia', flag: '🇱🇷' },
  { code: 'LS', name: 'Lesotho', flag: '🇱🇸' },
  { code: 'LT', name: 'Lituanie', flag: '🇱🇹' },
  { code: 'LU', name: 'Luxembourg', flag: '🇱🇺' },
  { code: 'LV', name: 'Lettonie', flag: '🇱🇻' },
  { code: 'LY', name: 'Libye', flag: '🇱🇾' },
  { code: 'MA', name: 'Maroc', flag: '🇲🇦' },
  { code: 'MC', name: 'Monaco', flag: '🇲🇨' },
  { code: 'MD', name: 'Moldavie', flag: '🇲🇩' },
  { code: 'ME', name: 'Monténégro', flag: '🇲🇪' },
  { code: 'MF', name: 'Saint-Martin', flag: '🇲🇫' },
  { code: 'MG', name: 'Madagascar', flag: '🇲🇬' },
  { code: 'MH', name: 'Îles Marshall', flag: '🇲🇭' },
  { code: 'MK', name: 'Macédoine du Nord', flag: '🇲🇰' },
  { code: 'ML', name: 'Mali', flag: '🇲🇱' },
  { code: 'MM', name: 'Myanmar', flag: '🇲🇲' },
  { code: 'MN', name: 'Mongolie', flag: '🇲🇳' },
  { code: 'MO', name: 'Macao', flag: '🇲🇴' },
  { code: 'MP', name: 'Îles Mariannes du Nord', flag: '🇲🇵' },
  { code: 'MQ', name: 'Martinique', flag: '🇲🇶' },
  { code: 'MR', name: 'Mauritanie', flag: '🇲🇷' },
  { code: 'MS', name: 'Montserrat', flag: '🇲🇸' },
  { code: 'MT', name: 'Malte', flag: '🇲🇹' },
  { code: 'MU', name: 'Maurice', flag: '🇲🇺' },
  { code: 'MV', name: 'Maldives', flag: '🇲🇻' },
  { code: 'MW', name: 'Malawi', flag: '🇲🇼' },
  { code: 'MX', name: 'Mexique', flag: '🇲🇽' },
  { code: 'MY', name: 'Malaisie', flag: '🇲🇾' },
  { code: 'MZ', name: 'Mozambique', flag: '🇲🇿' },
  { code: 'NA', name: 'Namibie', flag: '🇳🇦' },
  { code: 'NC', name: 'Nouvelle-Calédonie', flag: '🇳🇨' },
  { code: 'NE', name: 'Niger', flag: '🇳🇪' },
  { code: 'NF', name: 'Île Norfolk', flag: '🇳🇫' },
  { code: 'NG', name: 'Nigeria', flag: '🇳🇬' },
  { code: 'NI', name: 'Nicaragua', flag: '🇳🇮' },
  { code: 'NL', name: 'Pays-Bas', flag: '🇳🇱' },
  { code: 'NO', name: 'Norvège', flag: '🇳🇴' },
  { code: 'NP', name: 'Népal', flag: '🇳🇵' },
  { code: 'NR', name: 'Nauru', flag: '🇳🇷' },
  { code: 'NU', name: 'Niue', flag: '🇳🇺' },
  { code: 'NZ', name: 'Nouvelle-Zélande', flag: '🇳🇿' },
  { code: 'OM', name: 'Oman', flag: '🇴🇲' },
  { code: 'PA', name: 'Panama', flag: '🇵🇦' },
  { code: 'PE', name: 'Pérou', flag: '🇵🇪' },
  { code: 'PF', name: 'Polynésie française', flag: '🇵🇫' },
  { code: 'PG', name: 'Papouasie-Nouvelle-Guinée', flag: '🇵🇬' },
  { code: 'PH', name: 'Philippines', flag: '🇵🇭' },
  { code: 'PK', name: 'Pakistan', flag: '🇵🇰' },
  { code: 'PL', name: 'Pologne', flag: '🇵🇱' },
  { code: 'PM', name: 'Saint-Pierre-et-Miquelon', flag: '🇵🇲' },
  { code: 'PN', name: 'Îles Pitcairn', flag: '🇵🇳' },
  { code: 'PR', name: 'Porto Rico', flag: '🇵🇷' },
  { code: 'PS', name: 'Palestine', flag: '🇵🇸' },
  { code: 'PT', name: 'Portugal', flag: '🇵🇹' },
  { code: 'PW', name: 'Palaos', flag: '🇵🇼' },
  { code: 'PY', name: 'Paraguay', flag: '🇵🇾' },
  { code: 'QA', name: 'Qatar', flag: '🇶🇦' },
  { code: 'RE', name: 'La Réunion', flag: '🇷🇪' },
  { code: 'RO', name: 'Roumanie', flag: '🇷🇴' },
  { code: 'RS', name: 'Serbie', flag: '🇷🇸' },
  { code: 'RU', name: 'Russie', flag: '🇷🇺' },
  { code: 'RW', name: 'Rwanda', flag: '🇷🇼' },
  { code: 'SA', name: 'Arabie saoudite', flag: '🇸🇦' },
  { code: 'SB', name: 'Îles Salomon', flag: '🇸🇧' },
  { code: 'SC', name: 'Seychelles', flag: '🇸🇨' },
  { code: 'SD', name: 'Soudan', flag: '🇸🇩' },
  { code: 'SE', name: 'Suède', flag: '🇸🇪' },
  { code: 'SG', name: 'Singapour', flag: '🇸🇬' },
  { code: 'SH', name: 'Sainte-Hélène', flag: '🇸🇭' },
  { code: 'SI', name: 'Slovénie', flag: '🇸🇮' },
  { code: 'SJ', name: 'Svalbard et Jan Mayen', flag: '🇸🇯' },
  { code: 'SK', name: 'Slovaquie', flag: '🇸🇰' },
  { code: 'SL', name: 'Sierra Leone', flag: '🇸🇱' },
  { code: 'SM', name: 'Saint-Marin', flag: '🇸🇲' },
  { code: 'SN', name: 'Sénégal', flag: '🇸🇳' },
  { code: 'SO', name: 'Somalie', flag: '🇸🇴' },
  { code: 'SR', name: 'Suriname', flag: '🇸🇷' },
  { code: 'SS', name: 'Soudan du Sud', flag: '🇸🇸' },
  { code: 'ST', name: 'Sao Tomé-et-Principe', flag: '🇸🇹' },
  { code: 'SV', name: 'El Salvador', flag: '🇸🇻' },
  { code: 'SX', name: 'Saint-Martin', flag: '🇸🇽' },
  { code: 'SY', name: 'Syrie', flag: '🇸🇾' },
  { code: 'SZ', name: 'Eswatini', flag: '🇸🇿' },
  { code: 'TC', name: 'Îles Turks-et-Caïcos', flag: '🇹🇨' },
  { code: 'TD', name: 'Tchad', flag: '🇹🇩' },
  { code: 'TF', name: 'Terres australes françaises', flag: '🇹🇫' },
  { code: 'TG', name: 'Togo', flag: '🇹🇬' },
  { code: 'TH', name: 'Thaïlande', flag: '🇹🇭' },
  { code: 'TJ', name: 'Tadjikistan', flag: '🇹🇯' },
  { code: 'TK', name: 'Tokelau', flag: '🇹🇰' },
  { code: 'TL', name: 'Timor oriental', flag: '🇹🇱' },
  { code: 'TM', name: 'Turkménistan', flag: '🇹🇲' },
  { code: 'TN', name: 'Tunisie', flag: '🇹🇳' },
  { code: 'TO', name: 'Tonga', flag: '🇹🇴' },
  { code: 'TR', name: 'Turquie', flag: '🇹🇷' },
  { code: 'TT', name: 'Trinité-et-Tobago', flag: '🇹🇹' },
  { code: 'TV', name: 'Tuvalu', flag: '🇹🇻' },
  { code: 'TW', name: 'Taïwan', flag: '🇹🇼' },
  { code: 'TZ', name: 'Tanzanie', flag: '🇹🇿' },
  { code: 'UA', name: 'Ukraine', flag: '🇺🇦' },
  { code: 'UG', name: 'Ouganda', flag: '🇺🇬' },
  { code: 'UM', name: 'Îles mineures éloignées des États-Unis', flag: '🇺🇲' },
  { code: 'US', name: 'États-Unis', flag: '🇺🇸' },
  { code: 'UY', name: 'Uruguay', flag: '🇺🇾' },
  { code: 'UZ', name: 'Ouzbékistan', flag: '🇺🇿' },
  { code: 'VA', name: 'Vatican', flag: '🇻🇦' },
  { code: 'VC', name: 'Saint-Vincent-et-les-Grenadines', flag: '🇻🇨' },
  { code: 'VE', name: 'Venezuela', flag: '🇻🇪' },
  { code: 'VG', name: 'Îles Vierges britanniques', flag: '🇻🇬' },
  { code: 'VI', name: 'Îles Vierges américaines', flag: '🇻🇮' },
  { code: 'VN', name: 'Vietnam', flag: '🇻🇳' },
  { code: 'VU', name: 'Vanuatu', flag: '🇻🇺' },
  { code: 'WF', name: 'Wallis-et-Futuna', flag: '🇼🇫' },
  { code: 'WS', name: 'Samoa', flag: '🇼🇸' },
  { code: 'YE', name: 'Yémen', flag: '🇾🇪' },
  { code: 'YT', name: 'Mayotte', flag: '🇾🇹' },
  { code: 'ZA', name: 'Afrique du Sud', flag: '🇿🇦' },
  { code: 'ZM', name: 'Zambie', flag: '🇿🇲' },
  { code: 'ZW', name: 'Zimbabwe', flag: '🇿🇼' }
])

// Computed
const filteredCountries = computed(() => {
  let countries = availableCountries.value

  // Filtrer par recherche
  if (countrySearch.value.trim()) {
    const search = countrySearch.value.toLowerCase().trim()
    countries = countries.filter(country => 
      country.name.toLowerCase().includes(search) ||
      country.code.toLowerCase().includes(search)
    )
  }

  // Filtrer par statut
  if (countryFilter.value === 'active') {
    countries = countries.filter(country => isCountrySupported(country.code))
  } else if (countryFilter.value === 'inactive') {
    countries = countries.filter(country => !isCountrySupported(country.code))
  }

  return countries
})

// Methods
async function loadConfiguration() {
  try {
    await adminStore.fetchSystemConfig()
    if (adminStore.systemConfig && Object.keys(adminStore.systemConfig).length > 0) {
      // Mapper les données de la base vers le format du composant
      const dbConfig = adminStore.systemConfig
      
      config.value = {
        ...defaultConfig,
        // Mapper les clés de la base de données vers les champs du composant
        points_per_dollar: dbConfig.points_per_dollar || defaultConfig.points_per_dollar,
        min_wallet_recharge: dbConfig.min_wallet_recharge || defaultConfig.min_wallet_recharge,
        new_service_days: dbConfig.new_service_days || defaultConfig.new_service_days,
        api_rate_limit: {
          requests_per_minute: dbConfig.api_rate_limit?.requests_per_minute || defaultConfig.api_rate_limit.requests_per_minute
        },
        supported_countries: dbConfig.supported_countries || defaultConfig.supported_countries,
        // Champs additionnels non stockés dans la base (pour l'instant)
        maintenance_mode: dbConfig.maintenance_mode || defaultConfig.maintenance_mode,
        maintenance_message: dbConfig.maintenance_message || defaultConfig.maintenance_message,
        api_timeout_seconds: dbConfig.api_timeout_seconds || defaultConfig.api_timeout_seconds,
        max_retries: dbConfig.max_retries || defaultConfig.max_retries,
        auto_backup_enabled: dbConfig.auto_backup_enabled || defaultConfig.auto_backup_enabled,
        backup_retention_days: dbConfig.backup_retention_days || defaultConfig.backup_retention_days
      }
    }
  } catch (error) {
    console.error('Erreur lors du chargement de la configuration:', error)
  }
}

async function saveConfiguration() {
  try {
    // Sauvegarder chaque clé de configuration individuellement
    const configUpdates = [
      { key: 'points_per_dollar', value: config.value.points_per_dollar, description: 'Number of points per USD' },
      { key: 'min_wallet_recharge', value: config.value.min_wallet_recharge, description: 'Minimum points for wallet recharge' },
      { key: 'new_service_days', value: config.value.new_service_days, description: 'Days to show new badge on services' },
      { key: 'api_rate_limit', value: config.value.api_rate_limit, description: 'API rate limiting configuration' },
      { key: 'supported_countries', value: config.value.supported_countries, description: 'List of supported countries' },
      // Champs additionnels si nécessaire
      { key: 'maintenance_mode', value: config.value.maintenance_mode, description: 'Maintenance mode status' },
      { key: 'maintenance_message', value: config.value.maintenance_message, description: 'Maintenance mode message' },
      { key: 'api_timeout_seconds', value: config.value.api_timeout_seconds, description: 'API timeout in seconds' },
      { key: 'max_retries', value: config.value.max_retries, description: 'Maximum API retries' },
      { key: 'auto_backup_enabled', value: config.value.auto_backup_enabled, description: 'Automatic backup enabled' },
      { key: 'backup_retention_days', value: config.value.backup_retention_days, description: 'Backup retention in days' }
    ]

    // Sauvegarder chaque configuration
    for (const { key, value, description } of configUpdates) {
      await adminStore.updateSystemConfig(key, value, description)
    }

    // Recharger la configuration pour synchroniser
    await loadConfiguration()
    
    console.log('Configuration sauvegardée avec succès')
  } catch (error) {
    console.error('Erreur lors de la sauvegarde de la configuration:', error)
  }
}

function resetToDefaults() {
  if (confirm('Êtes-vous sûr de vouloir réinitialiser la configuration aux valeurs par défaut ?')) {
    config.value = { ...defaultConfig }
  }
}

async function createManualBackup() {
  try {
    // Simuler la création d'une sauvegarde
    const backupData = {
      timestamp: new Date().toISOString(),
      configuration: config.value,
      services: adminStore.aiServices,
      categories: adminStore.serviceCategories,
      pricing: adminStore.servicePricing
    }
    
    const blob = new Blob([JSON.stringify(backupData, null, 2)], {
      type: 'application/json'
    })
    
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `backup-${new Date().toISOString().split('T')[0]}.json`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  } catch (error) {
    console.error('Erreur lors de la création de la sauvegarde:', error)
  }
}

async function downloadConfiguration() {
  try {
    const blob = new Blob([JSON.stringify(config.value, null, 2)], {
      type: 'application/json'
    })
    
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `configuration-${new Date().toISOString().split('T')[0]}.json`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  } catch (error) {
    console.error('Erreur lors de l\'export de la configuration:', error)
  }
}

// Méthodes pour la gestion des pays
function isCountrySupported(countryCode) {
  return config.value.supported_countries.includes(countryCode)
}

function toggleCountry(countryCode) {
  const index = config.value.supported_countries.indexOf(countryCode)
  if (index > -1) {
    // Retirer le pays de la liste
    config.value.supported_countries.splice(index, 1)
  } else {
    // Ajouter le pays à la liste
    config.value.supported_countries.push(countryCode)
  }
}

function selectAllCountries() {
  // Sélectionner tous les pays filtrés
  const filteredCodes = filteredCountries.value.map(country => country.code)
  
  // Ajouter les codes des pays filtrés qui ne sont pas déjà sélectionnés
  filteredCodes.forEach(code => {
    if (!config.value.supported_countries.includes(code)) {
      config.value.supported_countries.push(code)
    }
  })
}

function deselectAllCountries() {
  // Désélectionner tous les pays filtrés
  const filteredCodes = filteredCountries.value.map(country => country.code)
  
  // Retirer les codes des pays filtrés de la liste des pays supportés
  config.value.supported_countries = config.value.supported_countries.filter(
    code => !filteredCodes.includes(code)
  )
}

function resetCountryFilters() {
  countrySearch.value = ''
  countryFilter.value = 'all'
}

// Lifecycle
onMounted(async () => {
  await loadConfiguration()
})
</script>