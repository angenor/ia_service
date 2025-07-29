<template>
  <div class="h-full bg-white dark:bg-gray-800 shadow-lg border-r border-gray-200 dark:border-gray-700">
    <!-- En-tête du sidebar -->
    <div class="p-6 border-b border-gray-200 dark:border-gray-700">
      <div class="flex items-center">
        <div class="flex items-center justify-center w-10 h-10 bg-indigo-600 rounded-lg">
          <font-awesome-icon icon="cog" class="text-white text-lg" />
        </div>
        <div class="ml-3">
          <h2 class="text-lg font-semibold text-gray-900 dark:text-white">
            {{ $t('admin.sidebar.title') }}
          </h2>
          <p class="text-sm text-gray-500 dark:text-gray-400">
            {{ $t('admin.sidebar.subtitle') }}
          </p>
        </div>
      </div>
    </div>

    <!-- Navigation -->
    <nav class="p-4 space-y-2">
      <div
        v-for="item in navigationItems"
        :key="item.key"
        @click="$emit('navigate', item.key)"
        :class="[
          'flex items-center px-4 py-3 text-sm font-medium rounded-lg cursor-pointer transition-colors',
          activeSection === item.key
            ? 'bg-indigo-100 dark:bg-indigo-900/50 text-indigo-700 dark:text-indigo-300'
            : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
        ]"
      >
        <font-awesome-icon 
          :icon="item.icon" 
          :class="[
            'mr-3 text-lg',
            activeSection === item.key
              ? 'text-indigo-600 dark:text-indigo-400'
              : 'text-gray-400 dark:text-gray-500'
          ]"
        />
        <span>{{ $t(item.label) }}</span>
        <div v-if="item.badge" class="ml-auto">
          <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800 dark:bg-red-900/20 dark:text-red-400">
            {{ item.badge }}
          </span>
        </div>
      </div>
    </nav>

    <!-- Section des statistiques rapides -->
    <div class="p-4 mt-6 border-t border-gray-200 dark:border-gray-700">
      <h3 class="text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-3">
        {{ $t('admin.sidebar.quickStats') }}
      </h3>
      
      <div class="space-y-3">
        <div class="flex items-center justify-between">
          <span class="text-sm text-gray-600 dark:text-gray-400">
            {{ $t('admin.dashboard.totalUsers') }}
          </span>
          <span class="text-sm font-medium text-gray-900 dark:text-white">
            {{ adminStore.totalUsers || 0 }}
          </span>
        </div>
        
        <div class="flex items-center justify-between">
          <span class="text-sm text-gray-600 dark:text-gray-400">
            {{ $t('admin.dashboard.activeServices') }}
          </span>
          <span class="text-sm font-medium text-gray-900 dark:text-white">
            {{ adminStore.activeServices.length || 0 }}
          </span>
        </div>
        
        <div class="flex items-center justify-between">
          <span class="text-sm text-gray-600 dark:text-gray-400">
            {{ $t('admin.dashboard.totalRevenue') }}
          </span>
          <span class="text-sm font-medium text-green-600 dark:text-green-400">
            {{ formatCurrency(adminStore.totalRevenue || 0) }}
          </span>
        </div>
      </div>
    </div>

    <!-- Actions rapides -->
    <div class="p-4 border-t border-gray-200 dark:border-gray-700">
      <h3 class="text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-3">
        {{ $t('admin.sidebar.quickActions') }}
      </h3>
      
      <div class="space-y-2">
        <button
          @click="$emit('refresh-data')"
          class="w-full flex items-center px-3 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-md transition-colors"
        >
          <font-awesome-icon icon="sync" class="mr-2 text-gray-400" />
          {{ $t('admin.sidebar.refreshData') }}
        </button>
        
        <button
          @click="$emit('export-reports')"
          class="w-full flex items-center px-3 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-md transition-colors"
        >
          <font-awesome-icon icon="download" class="mr-2 text-gray-400" />
          {{ $t('admin.sidebar.exportReports') }}
        </button>
      </div>
    </div>

    <!-- Footer du sidebar -->
    <div class="p-4 border-t border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-900">
      <div class="flex items-center">
        <div class="flex items-center justify-center w-8 h-8 bg-green-100 dark:bg-green-900/20 rounded-full">
          <div class="w-2 h-2 bg-green-500 rounded-full"></div>
        </div>
        <div class="ml-3">
          <p class="text-xs font-medium text-gray-900 dark:text-white">
            {{ $t('admin.sidebar.systemStatus') }}
          </p>
          <p class="text-xs text-green-600 dark:text-green-400">
            {{ $t('admin.sidebar.online') }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useAdminStore } from '@/stores/admin'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const adminStore = useAdminStore()

// Props
const props = defineProps({
  activeSection: {
    type: String,
    default: 'dashboard'
  }
})

// Events
defineEmits(['navigate', 'refresh-data', 'export-reports'])

// Navigation items
const navigationItems = computed(() => [
  {
    key: 'dashboard',
    label: 'admin.sidebar.dashboard',
    icon: 'chart-line'
  },
  {
    key: 'services',
    label: 'admin.sidebar.services',
    icon: 'cogs'
  },
  {
    key: 'pricing',
    label: 'admin.sidebar.pricing',
    icon: 'dollar-sign'
  },
  {
    key: 'promotions',
    label: 'admin.sidebar.promotions',
    icon: 'tags'
  },
  {
    key: 'users',
    label: 'admin.sidebar.users',
    icon: 'users',
    badge: getNewUsersCount()
  },
  {
    key: 'system',
    label: 'admin.sidebar.system',
    icon: 'cog'
  },
  {
    key: 'monitoring',
    label: 'admin.sidebar.monitoring',
    icon: 'chart-bar'
  }
])

// Methods
function formatCurrency(amount) {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'EUR'
  }).format(amount || 0)
}

function getNewUsersCount() {
  // Compter les nouveaux utilisateurs des 7 derniers jours
  const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
  const newUsers = adminStore.users.filter(user => 
    new Date(user.created_at) > sevenDaysAgo
  )
  return newUsers.length > 0 ? newUsers.length : null
}
</script>