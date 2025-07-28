<template>
  <div class="space-y-6">
    <!-- En-tête -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <h2 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">
        {{ $t('admin.pricing.title') }}
      </h2>
      
      <div class="flex items-center space-x-4">
        <select 
          v-model="selectedService" 
          @change="fetchPricingData"
          class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
        >
          <option value="">Tous les services</option>
          <option v-for="service in adminStore.aiServices" :key="service.id" :value="service.id">
            {{ service.display_name || service.name }}
          </option>
        </select>
        
        <button
          @click="showAddPricingModal = true"
          class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors flex items-center"
        >
          <font-awesome-icon icon="plus" class="mr-2" />
          {{ $t('admin.pricing.addCountryPricing') }}
        </button>
      </div>
    </div>

    <!-- Prix par pays -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">
        {{ $t('admin.pricing.byCountry') }}
      </h3>
      
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-700">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Service
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.pricing.country') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.pricing.basePricePoints') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.pricing.apiCost') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.pricing.profitMargin') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.pricing.lastUpdated') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.common.actions') }}
              </th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
            <tr v-for="pricing in filteredPricing" :key="`${pricing.service_id}-${pricing.country_code}`">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">
                {{ pricing.ai_services?.display_name || pricing.ai_services?.name }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                <div class="flex items-center">
                  <span class="mr-2">{{ getCountryFlag(pricing.country_code) }}</span>
                  {{ getCountryName(pricing.country_code) }}
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ pricing.base_price_points }} points
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                ${{ pricing.api_cost_per_request?.toFixed(4) || '0.0000' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm">
                <span :class="getProfitMarginClass(calculateProfitMargin(pricing))">
                  {{ calculateProfitMargin(pricing) }}%
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ formatDate(pricing.updated_at) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                <button
                  @click="openEditPricingModal(pricing)"
                  class="text-blue-600 hover:text-blue-900 dark:text-blue-400 dark:hover:text-blue-300"
                >
                  <font-awesome-icon icon="edit" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Disponibilité par pays -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">
        {{ $t('admin.pricing.availability') }}
      </h3>
      
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div v-for="country in supportedCountries" :key="country.code" 
             class="p-4 border border-gray-200 dark:border-gray-600 rounded-lg">
          <div class="flex items-center justify-between">
            <div class="flex items-center">
              <span class="text-2xl mr-3">{{ country.flag }}</span>
              <div>
                <h4 class="text-sm font-medium text-gray-900 dark:text-white">{{ country.name }}</h4>
                <p class="text-xs text-gray-500 dark:text-gray-400">{{ country.code }}</p>
              </div>
            </div>
            <div class="text-right">
              <p class="text-sm font-medium text-gray-900 dark:text-white">
                {{ getActiveServicesForCountry(country.code) }} services
              </p>
              <p class="text-xs text-gray-500 dark:text-gray-400">actifs</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Historique des prix -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-medium text-gray-900 dark:text-white">
          {{ $t('admin.pricing.priceHistory') }}
        </h3>
        <button
          @click="fetchPriceHistory"
          class="px-3 py-2 text-sm bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-md hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
        >
          <font-awesome-icon icon="sync" :class="{ 'animate-spin': isLoadingHistory }" />
        </button>
      </div>
      
      <div v-if="priceHistory.length === 0" class="text-center py-8 text-gray-500 dark:text-gray-400">
        {{ $t('admin.common.noData') }}
      </div>
      
      <div v-else class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-700">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Service
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Pays
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Ancien prix
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Nouveau prix
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Date
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Modifié par
              </th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
            <tr v-for="history in priceHistory" :key="history.id">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">
                {{ history.service_name }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ getCountryName(history.country_code) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ history.old_price }} points
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ history.new_price }} points
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ formatDate(history.changed_at) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ history.changed_by_email }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal pour ajouter/modifier tarification -->
    <PricingModal
      v-if="showPricingModal"
      :pricing="selectedPricing"
      :services="adminStore.aiServices"
      :countries="supportedCountries"
      @close="closePricingModal"
      @save="savePricing"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAdminStore } from '@/stores/admin'
import { useI18n } from 'vue-i18n'

// Composant modal
import PricingModal from './modals/PricingModal.vue'

const { t } = useI18n()
const adminStore = useAdminStore()

// État local
const selectedService = ref('')
const showPricingModal = ref(false)
const showAddPricingModal = ref(false)
const selectedPricing = ref(null)
const priceHistory = ref([])
const isLoadingHistory = ref(false)

// Pays supportés
const supportedCountries = ref([
  { code: 'US', name: 'États-Unis', flag: '🇺🇸' },
  { code: 'FR', name: 'France', flag: '🇫🇷' },
  { code: 'DE', name: 'Allemagne', flag: '🇩🇪' },
  { code: 'ES', name: 'Espagne', flag: '🇪🇸' },
  { code: 'IT', name: 'Italie', flag: '🇮🇹' },
  { code: 'GB', name: 'Royaume-Uni', flag: '🇬🇧' },
  { code: 'CA', name: 'Canada', flag: '🇨🇦' },
  { code: 'JP', name: 'Japon', flag: '🇯🇵' }
])

// Computed
const filteredPricing = computed(() => {
  if (!selectedService.value) {
    return adminStore.servicePricing
  }
  return adminStore.servicePricing.filter(p => p.service_id === selectedService.value)
})

// Methods
function getCountryFlag(countryCode) {
  const country = supportedCountries.value.find(c => c.code === countryCode)
  return country ? country.flag : '🏳️'
}

function getCountryName(countryCode) {
  const country = supportedCountries.value.find(c => c.code === countryCode)
  return country ? country.name : countryCode
}

function calculateProfitMargin(pricing) {
  if (!pricing.base_price_points || !pricing.api_cost_per_request) return 0
  
  // Supposons 1000 points = 1 USD pour les calculs
  const pointsToUsd = pricing.base_price_points / 1000
  const margin = ((pointsToUsd - pricing.api_cost_per_request) / pointsToUsd) * 100
  
  return Math.round(margin * 10) / 10
}

function getProfitMarginClass(percentage) {
  if (percentage >= 50) return 'text-green-600 dark:text-green-400'
  if (percentage >= 20) return 'text-yellow-600 dark:text-yellow-400'
  return 'text-red-600 dark:text-red-400'
}

function formatDate(dateString) {
  return new Date(dateString).toLocaleDateString('fr-FR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function getActiveServicesForCountry(countryCode) {
  return adminStore.servicePricing.filter(p => p.country_code === countryCode).length
}

async function fetchPricingData() {
  await adminStore.fetchServicePricing()
}

async function fetchPriceHistory() {
  isLoadingHistory.value = true
  try {
    // Simuler des données d'historique
    priceHistory.value = [
      {
        id: 1,
        service_name: 'GPT-4 Chat',
        country_code: 'FR',
        old_price: 10,
        new_price: 12,
        changed_at: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
        changed_by_email: 'admin@example.com'
      },
      {
        id: 2,
        service_name: 'DALL-E Image',
        country_code: 'US',
        old_price: 25,
        new_price: 20,
        changed_at: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString(),
        changed_by_email: 'admin@example.com'
      }
    ]
  } catch (error) {
    console.error('Erreur lors du chargement de l\'historique:', error)
  } finally {
    isLoadingHistory.value = false
  }
}

function openEditPricingModal(pricing) {
  selectedPricing.value = pricing
  showPricingModal.value = true
}

function closePricingModal() {
  showPricingModal.value = false
  showAddPricingModal.value = false
  selectedPricing.value = null
}

async function savePricing(pricingData) {
  try {
    await adminStore.updateServicePricing(
      pricingData.service_id,
      pricingData.country_code,
      pricingData
    )
    closePricingModal()
  } catch (error) {
    console.error('Erreur lors de la sauvegarde de la tarification:', error)
  }
}

// Lifecycle
onMounted(async () => {
  await Promise.all([
    adminStore.fetchServicePricing(),
    adminStore.fetchAiServices()
  ])
})
</script>