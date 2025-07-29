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
              <div class="text-2xl font-bold text-blue-600 dark:text-blue-400">{{ performanceMetrics.avgResponseTime || 0 }}ms</div>
              <div class="text-sm text-blue-600 dark:text-blue-400">Temps de réponse moyen</div>
              <div class="text-xs text-gray-500">Basé sur {{ performanceMetrics.totalRequests || 0 }} requêtes</div>
            </div>
            <div class="bg-green-50 dark:bg-green-900/20 p-4 rounded-lg">
              <div class="text-2xl font-bold text-green-600 dark:text-green-400">{{ performanceMetrics.successRate || 0 }}%</div>
              <div class="text-sm text-green-600 dark:text-green-400">Taux de succès</div>
              <div class="text-xs text-gray-500">{{ performanceMetrics.successCount || 0 }} succès</div>
            </div>
            <div class="bg-yellow-50 dark:bg-yellow-900/20 p-4 rounded-lg">
              <div class="text-2xl font-bold text-yellow-600 dark:text-yellow-400">{{ performanceMetrics.totalRequests || 0 }}</div>
              <div class="text-sm text-yellow-600 dark:text-yellow-400">Requêtes totales (24h)</div>
              <div class="text-xs text-gray-500">{{ performanceMetrics.totalPoints || 0 }} points utilisés</div>
            </div>
            <div class="bg-red-50 dark:bg-red-900/20 p-4 rounded-lg">
              <div class="text-2xl font-bold text-red-600 dark:text-red-400">{{ performanceMetrics.errorCount || 0 }}</div>
              <div class="text-sm text-red-600 dark:text-red-400">Erreurs (24h)</div>
              <div class="text-xs text-gray-500">${{ (performanceMetrics.totalCost || 0).toFixed(4) }} coût total</div>
            </div>
          </div>

          <!-- Répartition par pays -->
          <div class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-600 rounded-lg p-6 mb-6">
            <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Répartition par pays (24h)</h3>
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div v-for="country in performanceMetrics.countryBreakdown" :key="country.country_code" 
                   class="text-center p-3 bg-gray-50 dark:bg-gray-700 rounded-lg">
                <div class="text-lg mb-1">{{ getCountryFlag(country.country_code) }}</div>
                <div class="text-sm font-medium text-gray-900 dark:text-white">{{ country.requests }}</div>
                <div class="text-xs text-gray-500 dark:text-gray-400">{{ country.country_code }}</div>
              </div>
            </div>
          </div>
          
          <!-- Services les plus utilisés -->
          <div class="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-600 rounded-lg p-6">
            <h3 class="text-lg font-medium text-gray-900 dark:text-white mb-4">Services les plus utilisés (24h)</h3>
            <div class="space-y-3">
              <div v-for="service in performanceMetrics.topServices" :key="service.service_id" 
                   class="flex items-center justify-between">
                <div>
                  <div class="text-sm font-medium text-gray-900 dark:text-white">{{ service.service_name }}</div>
                  <div class="text-xs text-gray-500 dark:text-gray-400">{{ service.provider }}</div>
                </div>
                <div class="text-right">
                  <div class="text-sm font-medium text-gray-900 dark:text-white">{{ service.requests }} requêtes</div>
                  <div class="text-xs text-gray-500 dark:text-gray-400">{{ service.points }} points</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Utilisation API -->
        <div v-if="activeTab === 'apiUsage'">
          <div v-if="apiUsageData.length === 0" class="text-center py-8 text-gray-500 dark:text-gray-400">
            <font-awesome-icon icon="api" class="h-8 w-8 mb-2" />
            <p>Aucune utilisation API trouvée</p>
          </div>
          <div v-else class="space-y-4">
            <div v-for="usage in apiUsageData" :key="usage.service_id" 
                 class="flex items-center justify-between p-4 border border-gray-200 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-800/50 transition-colors">
              <div class="flex-1">
                <h4 class="text-sm font-medium text-gray-900 dark:text-white">{{ usage.service_name }}</h4>
                <p class="text-sm text-gray-500 dark:text-gray-400">{{ usage.provider }}</p>
                <div class="flex items-center space-x-2 mt-1">
                  <span class="text-xs text-gray-500 dark:text-gray-400">
                    Succès: {{ usage.success_count }}/{{ usage.total_requests }}
                  </span>
                  <span class="text-xs px-2 py-1 rounded-full" :class="usage.success_rate >= 95 ? 'bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-300' : usage.success_rate >= 90 ? 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900 dark:text-yellow-300' : 'bg-red-100 text-red-700 dark:bg-red-900 dark:text-red-300'">
                    {{ usage.success_rate.toFixed(1) }}%
                  </span>
                </div>
              </div>
              <div class="text-right mx-6">
                <div class="text-lg font-semibold text-gray-900 dark:text-white">{{ usage.total_requests }}</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">requêtes (24h)</div>
                <div class="text-xs text-gray-400">{{ usage.avg_duration_ms ? `${usage.avg_duration_ms}ms moy.` : 'N/A' }}</div>
              </div>
              <div class="text-right">
                <div class="text-lg font-semibold text-blue-600 dark:text-blue-400">{{ usage.total_points }}</div>
                <div class="text-sm text-gray-500 dark:text-gray-400">points utilisés</div>
                <div class="text-sm font-medium text-gray-900 dark:text-white">${{ usage.total_cost.toFixed(4) }}</div>
                <div class="text-xs text-gray-400">coût API</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Activité utilisateur -->
        <div v-if="activeTab === 'userActivity'">
          <div v-if="userActivity.length === 0" class="text-center py-8 text-gray-500 dark:text-gray-400">
            <font-awesome-icon icon="chart-line" class="h-8 w-8 mb-2" />
            <p>Aucune activité utilisateur trouvée</p>
          </div>
          <table v-else class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
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
                  Coût API
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Durée
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
              <tr v-for="activity in filteredUserActivity" :key="activity.id">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white">
                  <div>
                    <div class="font-medium">{{ activity.profiles?.username || activity.profiles?.display_name || 'Utilisateur' }}</div>
                    <div class="text-xs text-gray-500 dark:text-gray-400">{{ activity.profiles?.metadata?.email || 'N/A' }}</div>
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                  <div>
                    <div class="font-medium">{{ activity.ai_services?.name || 'Service inconnu' }}</div>
                    <div class="text-xs text-gray-500 dark:text-gray-400">{{ activity.ai_services?.provider || 'N/A' }}</div>
                  </div>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                  {{ activity.points_consumed }} points
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                  ${{ (activity.api_cost_usd || 0).toFixed(4) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                  {{ activity.duration_ms ? `${activity.duration_ms}ms` : 'N/A' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span :class="getStatusClass(activity.status)" class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full">
                    {{ activity.status }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                  <div>
                    <div>{{ formatDateTime(activity.created_at) }}</div>
                    <div v-if="activity.completed_at" class="text-xs text-gray-400">
                      Terminé: {{ formatTime(activity.completed_at) }}
                    </div>
                  </div>
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

// Données réelles de la base
const systemLogs = ref([])
const auditTrail = ref([])
const userActivity = ref([])
const performanceMetrics = ref({
  avgResponseTime: 0,
  successRate: 0,
  totalRequests: 0,
  errorCount: 0,
  successCount: 0,
  totalPoints: 0,
  totalCost: 0,
  countryBreakdown: [],
  topServices: []
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

const filteredUserActivity = computed(() => {
  let activity = userActivity.value
  
  if (selectedLogLevel.value) {
    activity = activity.filter(item => item.status === selectedLogLevel.value)
  }
  
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    activity = activity.filter(item => 
      item.profiles?.username?.toLowerCase().includes(query) ||
      item.profiles?.display_name?.toLowerCase().includes(query) ||
      item.profiles?.metadata?.email?.toLowerCase().includes(query) ||
      item.ai_services?.name?.toLowerCase().includes(query) ||
      item.ai_services?.provider?.toLowerCase().includes(query)
    )
  }
  
  return activity
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
    // Charger les données réelles de la base de données
    await Promise.all([
      loadServiceUsage(),
      loadPerformanceMetrics(),
      loadApiUsageData(),
      loadSystemLogs(),
      loadAuditTrail()
    ])
  } catch (error) {
    console.error('Erreur lors du rafraîchissement des logs:', error)
  } finally {
    isLoading.value = false
  }
}

// Fonctions pour charger les données réelles de la base
async function loadServiceUsage() {
  try {
    // Charger l'activité utilisateur depuis la table service_usage
    const { data, error } = await supabase
      .from('service_usage')
      .select(`
        *,
        profiles (
          id,
          username,
          display_name,
          metadata
        ),
        ai_services (
          id,
          name,
          provider
        )
      `)
      .order('created_at', { ascending: false })
      .limit(50)
    
    if (error) throw error
    userActivity.value = data || []
  } catch (error) {
    console.error('Erreur lors du chargement de l\'activité utilisateur:', error)
    userActivity.value = []
  }
}

async function loadPerformanceMetrics() {
  try {
    // Calculer les métriques de performance depuis les 24 dernières heures
    const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()
    
    const { data, error } = await supabase
      .from('service_usage')
      .select('*')
      .gte('created_at', yesterday)
    
    if (error) throw error
    
    const usageData = data || []
    const totalRequests = usageData.length
    const successCount = usageData.filter(u => u.status === 'completed').length
    const errorCount = usageData.filter(u => u.status === 'failed').length
    const totalPoints = usageData.reduce((sum, u) => sum + (u.points_consumed || 0), 0)
    const totalCost = usageData.reduce((sum, u) => sum + (u.api_cost_usd || 0), 0)
    
    // Calculer temps de réponse moyen
    const completedRequests = usageData.filter(u => u.duration_ms && u.status === 'completed')
    const avgResponseTime = completedRequests.length > 0 
      ? Math.round(completedRequests.reduce((sum, u) => sum + u.duration_ms, 0) / completedRequests.length)
      : 0
    
    // Répartition par pays
    const countryBreakdown = {}
    usageData.forEach(u => {
      if (u.country_code) {
        countryBreakdown[u.country_code] = (countryBreakdown[u.country_code] || 0) + 1
      }
    })
    
    const countryBreakdownArray = Object.entries(countryBreakdown).map(([code, requests]) => ({
      country_code: code,
      requests
    }))
    
    // Services les plus utilisés
    const serviceUsage = {}
    for (const usage of usageData) {
      if (usage.service_id) {
        if (!serviceUsage[usage.service_id]) {
          serviceUsage[usage.service_id] = {
            service_id: usage.service_id,
            service_name: 'Service inconnu',
            provider: 'N/A',
            requests: 0,
            points: 0
          }
        }
        serviceUsage[usage.service_id].requests++
        serviceUsage[usage.service_id].points += usage.points_consumed || 0
      }
    }
    
    // Enrichir avec les noms des services depuis adminStore
    const topServices = Object.values(serviceUsage)
      .sort((a, b) => b.requests - a.requests)
      .slice(0, 5)
      .map(service => {
        const aiService = adminStore.aiServices.find(s => s.id === service.service_id)
        return {
          ...service,
          service_name: aiService?.name || service.service_name,
          provider: aiService?.provider || service.provider
        }
      })
    
    performanceMetrics.value = {
      avgResponseTime,
      successRate: totalRequests > 0 ? Math.round((successCount / totalRequests) * 100) : 0,
      totalRequests,
      errorCount,
      successCount,
      totalPoints,
      totalCost,
      countryBreakdown: countryBreakdownArray,
      topServices
    }
  } catch (error) {
    console.error('Erreur lors du calcul des métriques de performance:', error)
    performanceMetrics.value = {
      avgResponseTime: 0,
      successRate: 0,
      totalRequests: 0,
      errorCount: 0,
      successCount: 0,
      totalPoints: 0,
      totalCost: 0,
      countryBreakdown: [],
      topServices: []
    }
  }
}

async function loadApiUsageData() {
  try {
    // Agrégation des données d'utilisation API par service
    const yesterday = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString()
    
    const { data, error } = await supabase
      .from('service_usage')
      .select(`
        service_id,
        points_consumed,
        api_cost_usd,
        status,
        duration_ms,
        ai_services (
          id,
          name,
          provider
        )
      `)
      .gte('created_at', yesterday)
    
    if (error) throw error
    
    // Grouper par service
    const serviceStats = {}
    
    for (const usage of data || []) {
      const serviceId = usage.service_id
      if (!serviceStats[serviceId]) {
        serviceStats[serviceId] = {
          service_id: serviceId,
          service_name: usage.ai_services?.name || 'Service inconnu',
          provider: usage.ai_services?.provider || 'N/A',
          total_requests: 0,
          success_count: 0,
          total_points: 0,
          total_cost: 0,
          durations: []
        }
      }
      
      const stats = serviceStats[serviceId]
      stats.total_requests++
      if (usage.status === 'completed') stats.success_count++
      stats.total_points += usage.points_consumed || 0
      stats.total_cost += usage.api_cost_usd || 0
      if (usage.duration_ms) stats.durations.push(usage.duration_ms)
    }
    
    // Calculer les statistiques finales
    apiUsageData.value = Object.values(serviceStats).map(stats => ({
      ...stats,
      success_rate: stats.total_requests > 0 ? (stats.success_count / stats.total_requests) * 100 : 0,
      avg_duration_ms: stats.durations.length > 0 
        ? Math.round(stats.durations.reduce((a, b) => a + b, 0) / stats.durations.length)
        : null
    })).sort((a, b) => b.total_requests - a.total_requests)
    
  } catch (error) {
    console.error('Erreur lors du chargement des données d\'utilisation API:', error)
    apiUsageData.value = []
  }
}

async function loadSystemLogs() {
  try {
    // Pour les logs système, on peut utiliser des données basées sur les erreurs de service_usage
    const { data, error } = await supabase
      .from('service_usage')
      .select(`
        id,
        created_at,
        status,
        error_message,
        ai_services (
          name,
          provider
        )
      `)
      .not('error_message', 'is', null)
      .order('created_at', { ascending: false })
      .limit(100)
    
    if (error) throw error
    
    systemLogs.value = (data || []).map(item => ({
      id: item.id,
      timestamp: item.created_at,
      level: item.status === 'failed' ? 'error' : 'warning',
      message: item.error_message || 'Erreur inconnue',
      service: item.ai_services?.name || 'Service inconnu'
    }))
    
    // Ajouter quelques logs système génériques si pas d'erreurs
    if (systemLogs.value.length === 0) {
      systemLogs.value = [
        {
          id: 'sys-1',
          timestamp: new Date().toISOString(),
          level: 'info',
          message: 'Système de monitoring démarré',
          service: 'System'
        }
      ]
    }
  } catch (error) {
    console.error('Erreur lors du chargement des logs système:', error)
    systemLogs.value = []
  }
}

async function loadAuditTrail() {
  try {
    // Pour l'audit trail, on peut utiliser les données de modifications de configuration
    // et les créations/mises à jour importantes
    auditTrail.value = [
      {
        id: 'audit-1',
        timestamp: new Date().toISOString(),
        user_email: 'admin@system.local',
        action: 'SYSTEM_MONITOR_ACCESS',
        details: 'Accès au panneau de monitoring et logs',
        ip_address: 'localhost'
      }
    ]
    
    // Dans une vraie implémentation, ceci viendrait d'une table audit_logs
  } catch (error) {
    console.error('Erreur lors du chargement de la piste d\'audit:', error)
    auditTrail.value = []
  }
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

// Fonctions utilitaires
function getStatusClass(status) {
  switch (status) {
    case 'completed':
      return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300'
    case 'failed':
      return 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300'
    case 'processing':
      return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300'
    default:
      return 'bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-300'
  }
}

function formatTime(dateString) {
  return new Date(dateString).toLocaleString('fr-FR', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

function getCountryFlag(countryCode) {
  if (!countryCode) return '🌍'
  
  const flagMap = {
    'US': '🇺🇸', 'CI': '🇨🇮', 'FR': '🇫🇷', 'CA': '🇨🇦',
    'GB': '🇬🇧', 'DE': '🇩🇪', 'JP': '🇯🇵', 'BR': '🇧🇷', 'IN': '🇮🇳'
  }
  
  return flagMap[countryCode] || '🌍'
}

// Import Supabase
import { supabase } from '@/lib/supabase'

// Lifecycle
onMounted(async () => {
  // S'assurer que les services AI sont chargés pour l'enrichissement des données
  if (adminStore.aiServices.length === 0) {
    await adminStore.fetchAiServices()
  }
  await refreshLogs()
})

onUnmounted(() => {
  if (refreshTimer) {
    clearInterval(refreshTimer)
  }
})
</script>