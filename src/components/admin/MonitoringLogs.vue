<template>
  <div class="space-y-6">
    <!-- En-tête avec contrôles -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <div class="flex items-center justify-between">
        <h2 class="text-xl font-semibold text-gray-900 dark:text-white">
          {{ $t('admin.monitoring.title') }}
        </h2>
        <div class="flex items-center space-x-3">
          <div class="flex items-center">
            <input
              v-model="autoRefresh"
              type="checkbox"
              id="auto-refresh"
              class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
            >
            <label for="auto-refresh" class="ml-2 text-sm text-gray-700 dark:text-gray-300">
              {{ $t('admin.monitoring.autoRefresh') }}
            </label>
          </div>
          <select 
            v-model="refreshInterval"
            :disabled="!autoRefresh"
            class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white disabled:opacity-50"
          >
            <option value="5000">5s</option>
            <option value="10000">10s</option>
            <option value="30000">30s</option>
            <option value="60000">1min</option>
          </select>
          <button
            @click="refreshLogs"
            :disabled="isLoading"
            class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors disabled:opacity-50"
          >
            <font-awesome-icon icon="sync" :class="{ 'animate-spin': isLoading }" class="mr-2" />
            {{ $t('admin.common.refresh') }}
          </button>
        </div>
      </div>
    </div>

    <!-- Onglets de monitoring -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <nav class="flex space-x-8 mb-6" aria-label="Tabs">
        <button
          v-for="tab in monitoringTabs"
          :key="tab.id"
          @click="activeTab = tab.id"
          :class="[
            'whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm',
            activeTab === tab.id
              ? 'border-blue-500 text-blue-600 dark:text-blue-400'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 dark:text-gray-400 dark:hover:text-gray-300'
          ]"
        >
          {{ $t(tab.label) }}
        </button>
      </nav>

      <!-- Filtres -->
      <div class="flex items-center space-x-4 mb-6">
        <select 
          v-model="selectedLogLevel"
          class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
        >
          <option value="">Tous les niveaux</option>
          <option value="info">Info</option>
          <option value="warning">Warning</option>
          <option value="error">Error</option>
          <option value="debug">Debug</option>
        </select>
        
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Rechercher dans les logs..."
          class="flex-1 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
        >
        
        <button
          @click="exportLogs"
          class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors"
        >
          <font-awesome-icon icon="download" class="mr-2" />
          {{ $t('admin.monitoring.exportLogs') }}
        </button>
        
        <button
          @click="clearLogs"
          class="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 transition-colors"
        >
          <font-awesome-icon icon="trash" class="mr-2" />
          {{ $t('admin.monitoring.clearLogs') }}
        </button>
      </div>

      <!-- Contenu des onglets -->
      <div class="overflow-x-auto">
        <!-- Logs système -->
        <div v-if="activeTab === 'systemLogs'">
          <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead class="bg-gray-50 dark:bg-gray-700">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  {{ $t('admin.monitoring.timestamp') }}
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  {{ $t('admin.monitoring.logLevel') }}
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Message
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Service
                </th>
              </tr>
            </thead>
            <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
              <tr v-for="log in filteredSystemLogs" :key="log.id">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                  {{ formatDateTime(log.timestamp) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span :class="getLogLevelClass(log.level)" class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full">
                    {{ log.level.toUpperCase() }}
                  </span>
                </td>
                <td class="px-6 py-4 text-sm text-gray-900 dark:text-white">
                  {{ log.message }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                  {{ log.service }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Piste d'audit -->
        <div v-if="activeTab === 'auditTrail'">
          <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead class="bg-gray-50 dark:bg-gray-700">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  {{ $t('admin.monitoring.timestamp') }}
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  {{ $t('admin.monitoring.user') }}
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  {{ $t('admin.monitoring.action') }}
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  {{ $t('admin.monitoring.details') }}
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  IP
                </th>
              </tr>
            </thead>
            <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
              <tr v-for="audit in filteredAuditTrail" :key="audit.id">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                  {{ formatDateTime(audit.timestamp) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                  {{ audit.user_email }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                  {{ audit.action }}
                </td>
                <td class="px-6 py-4 text-sm text-gray-500 dark:text-gray-300">
                  {{ audit.details }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                  {{ audit.ip_address }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Métriques de performance -->
        <div v-if="activeTab === 'performanceMetrics'">
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-6">
            <div class="bg-blue-50 dark:bg-blue-900/20 p-4 rounded-lg">
              <div class="text-2xl font-bold text-blue-600 dark:text-blue-400">{{ performanceMetrics.avgResponseTime }}ms</div>
              <div class="text-sm text-blue-600 dark:text-blue-400">Temps de réponse moyen</div>
            </div>
            <div class="bg-green-50 dark:bg-green-900/20 p-4 rounded-lg">
              <div class="text-2xl font-bold text-green-600 dark:text-green-400">{{ performanceMetrics.successRate }}%</div>
              <div class="text-sm text-green-600 dark:text-green-400">Taux de succès</div>
            </div>
            <div class="bg-yellow-50 dark:bg-yellow-900/20 p-4 rounded-lg">
              <div class="text-2xl font-bold text-yellow-600 dark:text-yellow-400">{{ performanceMetrics.totalRequests }}</div>
              <div class="text-sm text-yellow-600 dark:text-yellow-400">Requêtes totales (24h)</div>
            </div>
            <div class="bg-red-50 dark:bg-red-900/20 p-4 rounded-lg">
              <div class="text-2xl font-bold text-red-600 dark:text-red-400">{{ performanceMetrics.errorCount }}</div>
              <div class="text-sm text-red-600 dark:text-red-400">Erreurs (24h)</div>
            </div>
          </div>
          
          <!-- Graphique de performance (placeholder) -->
          <div class="h-64 bg-gray-100 dark:bg-gray-700 rounded-lg flex items-center justify-center">
            <p class="text-gray-500 dark:text-gray-400">Graphique de performance à implémenter</p>
          </div>
        </div>

        <!-- Utilisation API -->
        <div v-if="activeTab === 'apiUsage'">
          <div class="space-y-4">
            <div v-for="usage in apiUsageData" :key="usage.service" 
                 class="flex items-center justify-between p-4 border border-gray-200 dark:border-gray-600 rounded-lg">
              <div>
                <h4 class="text-sm font-medium text-gray-900 dark:text-white">{{ usage.service }}</h4>
                <p class="text-sm text-gray-500 dark:text-gray-400">{{ usage.provider }}</p>
              </div>
              <div class="text-right">
                <div class="text-lg font-semibold text-gray-900 dark:text-white">{{ usage.requests }}</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">requêtes (24h)</div>
              </div>
              <div class="text-right">
                <div class="text-lg font-semibold text-gray-900 dark:text-white">${{ usage.cost.toFixed(2) }}</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">coût estimé</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Activité utilisateur -->
        <div v-if="activeTab === 'userActivity'">
          <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead class="bg-gray-50 dark:bg-gray-700">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Utilisateur
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Service utilisé
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Points utilisés
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Statut
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  {{ $t('admin.monitoring.timestamp') }}
                </th>
              </tr>
            </thead>
            <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
              <tr v-for="activity in userActivity" :key="activity.id">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                  {{ activity.user_email }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                  {{ activity.service_name }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                  {{ activity.points_used }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span :class="activity.status === 'success' ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300' : 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300'"
                        class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full">
                    {{ activity.status }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                  {{ formatDateTime(activity.created_at) }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useAdminStore } from '@/stores/admin'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const adminStore = useAdminStore()

// État local
const activeTab = ref('systemLogs')
const autoRefresh = ref(false)
const refreshInterval = ref(30000)
const selectedLogLevel = ref('')
const searchQuery = ref('')
const isLoading = ref(false)
let refreshTimer = null

// Données simulées
const systemLogs = ref([])
const auditTrail = ref([])
const userActivity = ref([])
const performanceMetrics = ref({
  avgResponseTime: 245,
  successRate: 99.2,
  totalRequests: 15420,
  errorCount: 12
})
const apiUsageData = ref([])

// Configuration des onglets
const monitoringTabs = [
  { id: 'systemLogs', label: 'admin.monitoring.systemLogs' },
  { id: 'auditTrail', label: 'admin.monitoring.auditTrail' },
  { id: 'performanceMetrics', label: 'admin.monitoring.performanceMetrics' },
  { id: 'apiUsage', label: 'admin.monitoring.apiUsage' },
  { id: 'userActivity', label: 'admin.monitoring.userActivity' }
]

// Computed
const filteredSystemLogs = computed(() => {
  let logs = systemLogs.value
  
  if (selectedLogLevel.value) {
    logs = logs.filter(log => log.level === selectedLogLevel.value)
  }
  
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    logs = logs.filter(log => 
      log.message.toLowerCase().includes(query) ||
      log.service.toLowerCase().includes(query)
    )
  }
  
  return logs
})

const filteredAuditTrail = computed(() => {
  let audit = auditTrail.value
  
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    audit = audit.filter(item => 
      item.user_email.toLowerCase().includes(query) ||
      item.action.toLowerCase().includes(query) ||
      item.details.toLowerCase().includes(query)
    )
  }
  
  return audit
})

// Methods
function formatDateTime(dateString) {
  return new Date(dateString).toLocaleString('fr-FR')
}

function getLogLevelClass(level) {
  switch (level) {
    case 'error':
      return 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300'
    case 'warning':
      return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300'
    case 'info':
      return 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300'
    case 'debug':
      return 'bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-300'
    default:
      return 'bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-300'
  }
}

async function refreshLogs() {
  isLoading.value = true
  try {
    // Simuler le chargement des données
    await generateMockData()
  } catch (error) {
    console.error('Erreur lors du rafraîchissement des logs:', error)
  } finally {
    isLoading.value = false
  }
}

function generateMockData() {
  return new Promise(resolve => {
    setTimeout(() => {
      // Logs système
      systemLogs.value = [
        {
          id: 1,
          timestamp: new Date().toISOString(),
          level: 'info',
          message: 'Service OpenRouter API démarré avec succès',
          service: 'OpenRouter'
        },
        {
          id: 2,
          timestamp: new Date(Date.now() - 5 * 60 * 1000).toISOString(),
          level: 'warning',
          message: 'Délai de réponse élevé détecté',
          service: 'Fal.ai'
        },
        {
          id: 3,
          timestamp: new Date(Date.now() - 10 * 60 * 1000).toISOString(),
          level: 'error',
          message: 'Échec de connexion à l\'API externe',
          service: 'ElevenLabs'
        }
      ]
      
      // Piste d'audit
      auditTrail.value = [
        {
          id: 1,
          timestamp: new Date().toISOString(),
          user_email: 'admin@example.com',
          action: 'UPDATE_SERVICE_PRICING',
          details: 'Prix mis à jour pour GPT-4 Chat en France',
          ip_address: '192.168.1.100'
        },
        {
          id: 2,
          timestamp: new Date(Date.now() - 15 * 60 * 1000).toISOString(),
          user_email: 'admin@example.com',
          action: 'CREATE_PROMOTION',
          details: 'Nouvelle promotion WELCOME20 créée',
          ip_address: '192.168.1.100'
        }
      ]
      
      // Activité utilisateur
      userActivity.value = adminStore.serviceUsage.slice(0, 20)
      
      // Utilisation API
      apiUsageData.value = [
        { service: 'GPT-4 Chat', provider: 'OpenRouter', requests: 1250, cost: 125.50 },
        { service: 'DALL-E Image', provider: 'OpenAI', requests: 875, cost: 87.25 },
        { service: 'Claude Sonnet', provider: 'Anthropic', requests: 645, cost: 96.75 },
        { service: 'Stable Video', provider: 'Fal.ai', requests: 234, cost: 234.50 }
      ]
      
      resolve()
    }, 1000)
  })
}

function exportLogs() {
  const logsData = {
    systemLogs: filteredSystemLogs.value,
    auditTrail: filteredAuditTrail.value,
    userActivity: userActivity.value,
    exportedAt: new Date().toISOString()
  }
  
  const blob = new Blob([JSON.stringify(logsData, null, 2)], {
    type: 'application/json'
  })
  
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `logs-export-${new Date().toISOString().split('T')[0]}.json`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

function clearLogs() {
  if (confirm('Êtes-vous sûr de vouloir vider les logs ? Cette action est irréversible.')) {
    systemLogs.value = []
    auditTrail.value = []
    userActivity.value = []
  }
}

function startAutoRefresh() {
  if (refreshTimer) {
    clearInterval(refreshTimer)
  }
  
  if (autoRefresh.value) {
    refreshTimer = setInterval(() => {
      refreshLogs()
    }, refreshInterval.value)
  }
}

// Watchers
import { watch } from 'vue'

watch([autoRefresh, refreshInterval], () => {
  startAutoRefresh()
})

// Lifecycle
onMounted(async () => {
  await refreshLogs()
})

onUnmounted(() => {
  if (refreshTimer) {
    clearInterval(refreshTimer)
  }
})
</script>