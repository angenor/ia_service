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
              v-model.number="config.new_service_duration_days"
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
              v-model.number="config.rate_limit_per_minute"
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
          <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
            {{ $t('admin.config.supportedCountries') }}
          </label>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-2">
            <div v-for="country in availableCountries" :key="country.code" class="flex items-center">
              <input
                v-model="config.supported_countries"
                :value="country.code"
                type="checkbox"
                :id="`country-${country.code}`"
                class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              >
              <label :for="`country-${country.code}`" class="ml-2 text-sm text-gray-700 dark:text-gray-300">
                {{ country.flag }} {{ country.name }}
              </label>
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
import { ref, onMounted } from 'vue'
import { useAdminStore } from '@/stores/admin'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const adminStore = useAdminStore()

// Configuration par défaut
const defaultConfig = {
  points_per_dollar: 1000,
  min_wallet_recharge: 1000,
  new_service_duration_days: 30,
  rate_limit_per_minute: 60,
  maintenance_mode: false,
  maintenance_message: 'Maintenance en cours. Veuillez réessayer plus tard.',
  supported_countries: ['FR', 'US', 'DE', 'ES', 'IT', 'GB', 'CA'],
  api_timeout_seconds: 30,
  max_retries: 3,
  auto_backup_enabled: true,
  backup_retention_days: 30
}

// État local
const config = ref({ ...defaultConfig })

// Pays disponibles
const availableCountries = ref([
  { code: 'US', name: 'États-Unis', flag: '🇺🇸' },
  { code: 'FR', name: 'France', flag: '🇫🇷' },
  { code: 'DE', name: 'Allemagne', flag: '🇩🇪' },
  { code: 'ES', name: 'Espagne', flag: '🇪🇸' },
  { code: 'IT', name: 'Italie', flag: '🇮🇹' },
  { code: 'GB', name: 'Royaume-Uni', flag: '🇬🇧' },
  { code: 'CA', name: 'Canada', flag: '🇨🇦' },
  { code: 'JP', name: 'Japon', flag: '🇯🇵' },
  { code: 'CN', name: 'Chine', flag: '🇨🇳' },
  { code: 'AU', name: 'Australie', flag: '🇦🇺' },
  { code: 'BR', name: 'Brésil', flag: '🇧🇷' },
  { code: 'IN', name: 'Inde', flag: '🇮🇳' }
])

// Methods
async function loadConfiguration() {
  try {
    await adminStore.fetchSystemConfig()
    if (adminStore.systemConfig && Object.keys(adminStore.systemConfig).length > 0) {
      config.value = { ...defaultConfig, ...adminStore.systemConfig }
    }
  } catch (error) {
    console.error('Erreur lors du chargement de la configuration:', error)
  }
}

async function saveConfiguration() {
  try {
    await adminStore.updateSystemConfig(config.value)
    // Afficher un message de succès
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

// Lifecycle
onMounted(async () => {
  await loadConfiguration()
})
</script>