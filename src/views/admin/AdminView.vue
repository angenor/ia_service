<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-900 flex">
    <!-- Sidebar Admin -->
    <div class="w-80 flex-shrink-0">
      <AdminSidebar 
        :active-section="activeSection"
        @navigate="handleNavigation"
        @refresh-data="refreshAllData"
        @export-reports="exportReports"
      />
    </div>

    <!-- Contenu principal -->
    <div class="flex-1 flex flex-col overflow-hidden">
      <!-- En-tête -->
      <header class="bg-white dark:bg-gray-800 shadow-sm border-b border-gray-200 dark:border-gray-700">
        <div class="px-6 py-4">
          <div class="flex justify-between items-center">
            <div>
              <h1 class="text-2xl font-bold text-gray-900 dark:text-white">
                {{ getCurrentSectionTitle() }}
              </h1>
              <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
                {{ getCurrentSectionDescription() }}
              </p>
            </div>
            <div class="flex items-center space-x-4">
              <span class="text-sm text-gray-600 dark:text-gray-300">
                {{ $t('admin.welcome') }}, {{ authStore.userProfile?.display_name || authStore.userProfile?.username }}
              </span>
              <router-link 
                to="/" 
                class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 transition-colors"
              >
                <font-awesome-icon icon="chevron-left" class="mr-2" />
                {{ $t('admin.backToSite') }}
              </router-link>
            </div>
          </div>
        </div>
      </header>

      <!-- Zone de contenu principale -->
      <main class="flex-1 overflow-y-auto">
        <div class="p-6">
          <!-- Affichage conditionnel des erreurs -->
          <div v-if="adminStore.error" class="mb-6 bg-red-50 dark:bg-red-900/50 border border-red-200 dark:border-red-800 rounded-md p-4">
            <div class="flex">
              <font-awesome-icon icon="exclamation-triangle" class="h-5 w-5 text-red-400 mr-2" />
              <span class="text-sm text-red-700 dark:text-red-300">{{ adminStore.error }}</span>
              <button @click="adminStore.clearError()" class="ml-auto text-red-500 hover:text-red-700">
                <font-awesome-icon icon="times" />
              </button>
            </div>
          </div>

          <!-- Loading spinner global -->
          <div v-if="adminStore.isLoading && !hasData" class="flex justify-center py-12">
            <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
          </div>

          <!-- Contenu des sections -->
          <div v-else>
            <!-- Dashboard de Rentabilité -->
            <ProfitabilityDashboard v-if="activeSection === 'dashboard'" />

            <!-- Gestion des Services IA -->
            <AIServicesManagement v-if="activeSection === 'services'" />

            <!-- Gestion Tarifaire -->
            <PricingManagement v-if="activeSection === 'pricing'" />

            <!-- Système de Promotions -->
            <PromotionsManagement v-if="activeSection === 'promotions'" />

            <!-- Gestion des Utilisateurs -->
            <UsersManagement v-if="activeSection === 'users'" />

            <!-- Configuration Système -->
            <SystemConfiguration v-if="activeSection === 'system'" />

            <!-- Monitoring et Logs -->
            <MonitoringLogs v-if="activeSection === 'monitoring'" />
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAdminStore } from '@/stores/admin'
import { useAuthStore } from '@/stores/auth'
import { useI18n } from 'vue-i18n'

// Composants admin
import AdminSidebar from '@/components/admin/AdminSidebar.vue'
import ProfitabilityDashboard from '@/components/admin/ProfitabilityDashboard.vue'
import AIServicesManagement from '@/components/admin/AIServicesManagement.vue'
import PricingManagement from '@/components/admin/PricingManagement.vue'
import PromotionsManagement from '@/components/admin/PromotionsManagement.vue'
import UsersManagement from '@/components/admin/UsersManagement.vue'
import SystemConfiguration from '@/components/admin/SystemConfiguration.vue'
import MonitoringLogs from '@/components/admin/MonitoringLogs.vue'

const { t } = useI18n()
const adminStore = useAdminStore()
const authStore = useAuthStore()

// État local
const activeSection = ref('dashboard')

// Configuration des sections
const sections = {
  dashboard: {
    title: 'admin.sections.dashboard.title',
    description: 'admin.sections.dashboard.description'
  },
  services: {
    title: 'admin.sections.services.title',
    description: 'admin.sections.services.description'
  },
  pricing: {
    title: 'admin.sections.pricing.title',
    description: 'admin.sections.pricing.description'
  },
  promotions: {
    title: 'admin.sections.promotions.title',
    description: 'admin.sections.promotions.description'
  },
  users: {
    title: 'admin.sections.users.title',
    description: 'admin.sections.users.description'
  },
  system: {
    title: 'admin.sections.system.title',
    description: 'admin.sections.system.description'
  },
  monitoring: {
    title: 'admin.sections.monitoring.title',
    description: 'admin.sections.monitoring.description'
  }
}

// Computed
const hasData = computed(() => {
  return adminStore.serviceCategories.length > 0 || 
         adminStore.aiServices.length > 0 || 
         adminStore.users.length > 0
})

// Methods
function handleNavigation(sectionKey) {
  activeSection.value = sectionKey
}

function getCurrentSectionTitle() {
  return t(sections[activeSection.value]?.title || 'admin.sections.dashboard.title')
}

function getCurrentSectionDescription() {
  return t(sections[activeSection.value]?.description || 'admin.sections.dashboard.description')
}

async function refreshAllData() {
  try {
    await adminStore.initializeAdminData()
    console.log('Toutes les données ont été rafraîchies')
  } catch (error) {
    console.error('Erreur lors du rafraîchissement des données:', error)
    adminStore.setError('Erreur lors du rafraîchissement des données')
  }
}

async function exportReports() {
  try {
    const reportData = {
      timestamp: new Date().toISOString(),
      sections: {
        dashboard: {
          profitability: adminStore.profitabilityData,
          metrics: {
            totalUsers: adminStore.totalUsers,
            activeServices: adminStore.activeServices.length,
            totalRevenue: adminStore.totalRevenue
          }
        },
        services: {
          categories: adminStore.serviceCategories,
          subcategories: adminStore.serviceSubcategories,
          services: adminStore.aiServices
        },
        pricing: {
          pricing: adminStore.servicePricing,
          priceHistory: adminStore.priceHistory
        },
        promotions: adminStore.promotions,
        users: adminStore.users,
        system: adminStore.systemConfig,
        monitoring: {
          serviceUsage: adminStore.serviceUsage,
          transactions: adminStore.walletTransactions
        }
      }
    }

    const blob = new Blob([JSON.stringify(reportData, null, 2)], {
      type: 'application/json'
    })
    
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `admin-report-${new Date().toISOString().split('T')[0]}.json`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
    
    console.log('Rapport exporté avec succès')
  } catch (error) {
    console.error('Erreur lors de l\'export des rapports:', error)
    adminStore.setError('Erreur lors de l\'export des rapports')
  }
}

// Lifecycle
onMounted(async () => {
  try {
    await adminStore.initializeAdminData()
  } catch (error) {
    console.error('Erreur lors de l\'initialisation des données admin:', error)
  }
})
</script>