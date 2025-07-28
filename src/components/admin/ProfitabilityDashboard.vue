<template>
  <div class="space-y-6">
    <!-- En-tête avec métriques principales -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <div class="flex items-center justify-between mb-6">
        <h2 class="text-xl font-semibold text-gray-900 dark:text-white">
          {{ $t('admin.dashboard.title') }}
        </h2>
        <div class="flex items-center space-x-3">
          <select 
            v-model="selectedDateRange" 
            @change="fetchData"
            class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
          >
            <option value="7">{{ $t('admin.dashboard.last7Days') }}</option>
            <option value="30">{{ $t('admin.dashboard.last30Days') }}</option>
            <option value="thisMonth">{{ $t('admin.dashboard.thisMonth') }}</option>
            <option value="lastMonth">{{ $t('admin.dashboard.lastMonth') }}</option>
          </select>
          <button 
            @click="exportReport"
            class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors flex items-center"
          >
            <font-awesome-icon icon="download" class="mr-2" />
            {{ $t('admin.dashboard.exportReport') }}
          </button>
        </div>
      </div>

      <!-- Métriques principales -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div class="bg-gradient-to-r from-blue-500 to-blue-600 rounded-lg p-6 text-white">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-blue-100 text-sm">{{ $t('admin.dashboard.totalRevenue') }}</p>
              <p class="text-2xl font-semibold">{{ formatCurrency(metrics.totalRevenue) }}</p>
            </div>
            <font-awesome-icon icon="dollar-sign" class="text-3xl text-blue-200" />
          </div>
        </div>

        <div class="bg-gradient-to-r from-green-500 to-green-600 rounded-lg p-6 text-white">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-green-100 text-sm">{{ $t('admin.dashboard.totalUsers') }}</p>
              <p class="text-2xl font-semibold">{{ metrics.totalUsers.toLocaleString() }}</p>
            </div>
            <font-awesome-icon icon="users" class="text-3xl text-green-200" />
          </div>
        </div>

        <div class="bg-gradient-to-r from-purple-500 to-purple-600 rounded-lg p-6 text-white">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-purple-100 text-sm">{{ $t('admin.dashboard.activeServices') }}</p>
              <p class="text-2xl font-semibold">{{ metrics.activeServices }}</p>
            </div>
            <font-awesome-icon icon="cogs" class="text-3xl text-purple-200" />
          </div>
        </div>

        <div class="bg-gradient-to-r from-orange-500 to-orange-600 rounded-lg p-6 text-white">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-orange-100 text-sm">{{ $t('admin.dashboard.profitMargin') }}</p>
              <p class="text-2xl font-semibold">{{ metrics.profitMargin }}%</p>
            </div>
            <font-awesome-icon icon="chart-line" class="text-3xl text-orange-200" />
          </div>
        </div>
      </div>
    </div>

    <!-- Graphiques -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Graphique des revenus -->
      <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
        <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">
          {{ $t('admin.dashboard.revenueChart') }}
        </h3>
        <div class="h-64 flex items-center justify-center text-gray-500 dark:text-gray-400">
          <p>{{ $t('admin.common.loading') }}</p>
        </div>
      </div>

      <!-- Graphique d'utilisation -->
      <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
        <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">
          {{ $t('admin.dashboard.usageChart') }}
        </h3>
        <div class="h-64 flex items-center justify-center text-gray-500 dark:text-gray-400">
          <p>{{ $t('admin.common.loading') }}</p>
        </div>
      </div>
    </div>

    <!-- Tableaux de données -->
    <div class="grid grid-cols-1 xl:grid-cols-2 gap-6">
      <!-- Services les plus utilisés -->
      <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
        <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">
          {{ $t('admin.dashboard.topServices') }}
        </h3>
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead class="bg-gray-50 dark:bg-gray-700">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  {{ $t('admin.common.name') }}
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Utilisations
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Revenus
                </th>
              </tr>
            </thead>
            <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
              <tr v-for="service in topServices" :key="service.id">
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">
                  {{ service.name }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                  {{ service.usage_count.toLocaleString() }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                  {{ formatCurrency(service.revenue) }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Activité récente -->
      <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
        <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">
          {{ $t('admin.dashboard.recentActivity') }}
        </h3>
        <div class="space-y-4">
          <div 
            v-for="activity in recentActivity" 
            :key="activity.id"
            class="flex items-center space-x-3 p-3 rounded-lg bg-gray-50 dark:bg-gray-700"
          >
            <div class="flex-shrink-0">
              <div class="w-8 h-8 rounded-full bg-blue-100 dark:bg-blue-900 flex items-center justify-center">
                <font-awesome-icon icon="user" class="text-blue-600 dark:text-blue-400 text-sm" />
              </div>
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-sm text-gray-900 dark:text-white">
                {{ activity.user_email }} a utilisé {{ activity.service_name }}
              </p>
              <p class="text-xs text-gray-500 dark:text-gray-400">
                {{ formatDate(activity.created_at) }}
              </p>
            </div>
            <div class="text-sm text-gray-500 dark:text-gray-300">
              {{ activity.points_used }} points
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Données de rentabilité détaillées -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <div class="flex items-center justify-between mb-4">
        <h3 class="text-lg font-medium text-gray-900 dark:text-white">
          Données de rentabilité par service
        </h3>
        <button 
          @click="refreshProfitabilityData" 
          :disabled="adminStore.isLoading"
          class="px-3 py-2 text-sm bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-md hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
        >
          <font-awesome-icon icon="sync" :class="{ 'animate-spin': adminStore.isLoading }" />
        </button>
      </div>
      
      <div v-if="adminStore.profitabilityData.length === 0" class="text-center py-8 text-gray-500 dark:text-gray-400">
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
                Coût API
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Prix client
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Marge
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Utilisation (30j)
              </th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
            <tr v-for="item in adminStore.profitabilityData" :key="item.id">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">
                {{ item.name }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                ${{ item.api_cost_usd?.toFixed(4) || '0.0000' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ item.selling_price_points }} points
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm">
                <span :class="getProfitMarginClass(item.profit_margin_percentage)">
                  {{ item.profit_margin_percentage?.toFixed(1) || '0.0' }}%
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ item.total_uses || 0 }}
              </td>
            </tr>
          </tbody>
        </table>
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

// État local
const selectedDateRange = ref('30')
const metrics = ref({
  totalRevenue: 0,
  totalUsers: 0,
  activeServices: 0,
  profitMargin: 0
})
const topServices = ref([])
const recentActivity = ref([])

// Computed
const formattedProfitabilityData = computed(() => {
  return adminStore.profitabilityData || []
})

// Methods
function formatCurrency(amount) {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'EUR'
  }).format(amount || 0)
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

function getProfitMarginClass(percentage) {
  if (!percentage) return 'text-gray-500 dark:text-gray-400'
  if (percentage >= 50) return 'text-green-600 dark:text-green-400'
  if (percentage >= 20) return 'text-yellow-600 dark:text-yellow-400'
  return 'text-red-600 dark:text-red-400'
}

async function fetchData() {
  try {
    // Charger les données de rentabilité
    await adminStore.fetchProfitabilityData()
    
    // Simuler des métriques (à remplacer par de vraies données)
    metrics.value = {
      totalRevenue: adminStore.totalRevenue || 12580.50,
      totalUsers: adminStore.totalUsers || 247,
      activeServices: adminStore.activeServices.length || 15,
      profitMargin: 42.5
    }
    
    // Simuler des services populaires
    topServices.value = [
      { id: 1, name: 'GPT-4 Chat', usage_count: 1250, revenue: 3240.50 },
      { id: 2, name: 'DALL-E Image Generation', usage_count: 980, revenue: 2856.75 },
      { id: 3, name: 'Claude Sonnet', usage_count: 756, revenue: 1890.25 },
      { id: 4, name: 'Stable Video Diffusion', usage_count: 542, revenue: 1456.80 },
      { id: 5, name: 'ElevenLabs Voice', usage_count: 423, revenue: 987.60 }
    ]
    
    // Simuler l'activité récente
    recentActivity.value = [
      {
        id: 1,
        user_email: 'user1@example.com',
        service_name: 'GPT-4 Chat',
        points_used: 10,
        created_at: new Date(Date.now() - 5 * 60 * 1000).toISOString()
      },
      {
        id: 2,
        user_email: 'user2@example.com',
        service_name: 'DALL-E Image',
        points_used: 25,
        created_at: new Date(Date.now() - 12 * 60 * 1000).toISOString()
      },
      {
        id: 3,
        user_email: 'user3@example.com',
        service_name: 'Claude Sonnet',
        points_used: 15,
        created_at: new Date(Date.now() - 18 * 60 * 1000).toISOString()
      }
    ]
  } catch (error) {
    console.error('Erreur lors du chargement des données:', error)
  }
}

async function refreshProfitabilityData() {
  await adminStore.fetchProfitabilityData()
}

async function exportReport() {
  try {
    const reportData = {
      dateRange: selectedDateRange.value,
      metrics: metrics.value,
      topServices: topServices.value,
      profitabilityData: adminStore.profitabilityData,
      generatedAt: new Date().toISOString()
    }
    
    const blob = new Blob([JSON.stringify(reportData, null, 2)], {
      type: 'application/json'
    })
    
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `rapport-rentabilite-${new Date().toISOString().split('T')[0]}.json`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
  } catch (error) {
    console.error('Erreur lors de l\'export:', error)
  }
}

// Lifecycle
onMounted(() => {
  fetchData()
})
</script>