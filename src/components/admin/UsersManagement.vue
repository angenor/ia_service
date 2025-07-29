<template>
  <div class="space-y-6">
    <!-- En-tête avec filtres -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-xl font-semibold text-gray-900 dark:text-white">
          {{ $t('admin.users.title') }}
        </h2>
        <div class="flex items-center space-x-3">
          <button 
            @click="refreshUserStats"
            :disabled="adminStore.isLoading"
            class="px-3 py-2 text-sm bg-indigo-600 text-white rounded-md hover:bg-indigo-700 transition-colors disabled:opacity-50"
          >
            <font-awesome-icon icon="chart-bar" class="mr-2" />
            Statistiques
          </button>
          <select 
            v-model="userFilter"
            class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
          >
            <option value="all">{{ $t('admin.users.allUsers') }}</option>
            <option value="admin">{{ $t('admin.users.adminUsers') }}</option>
          </select>
          <div class="relative">
            <input 
              v-model="searchQuery"
              type="text" 
              :placeholder="$t('admin.common.search')"
              class="pl-10 pr-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            >
            <font-awesome-icon icon="search" class="absolute left-3 top-3 text-gray-400" />
          </div>
        </div>
      </div>

      <!-- Statistiques rapides -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div class="bg-blue-50 dark:bg-blue-900/20 p-4 rounded-lg">
          <div class="text-2xl font-bold text-blue-600 dark:text-blue-400">{{ adminStore.totalUsers }}</div>
          <div class="text-sm text-blue-600 dark:text-blue-400">{{ $t('admin.users.allUsers') }}</div>
        </div>
        <div class="bg-green-50 dark:bg-green-900/20 p-4 rounded-lg">
          <div class="text-2xl font-bold text-green-600 dark:text-green-400">{{ adminUsers.length }}</div>
          <div class="text-sm text-green-600 dark:text-green-400">{{ $t('admin.users.adminUsers') }}</div>
        </div>
        <div class="bg-yellow-50 dark:bg-yellow-900/20 p-4 rounded-lg">
          <div class="text-2xl font-bold text-yellow-600 dark:text-yellow-400">{{ activeUsers.length }}</div>
          <div class="text-sm text-yellow-600 dark:text-yellow-400">Actifs (30j)</div>
        </div>
        <div class="bg-purple-50 dark:bg-purple-900/20 p-4 rounded-lg">
          <div class="text-2xl font-bold text-purple-600 dark:text-purple-400">{{ formatCurrency(totalRevenue) }}</div>
          <div class="text-sm text-purple-600 dark:text-purple-400">Revenus totaux</div>
        </div>
      </div>
    </div>

    <!-- Tableau des utilisateurs -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-700">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.users.userProfile') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Pays / Langue
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.users.registrationDate') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Dernière Activité
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.users.walletBalance') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Statut
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.common.actions') }}
              </th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
            <tr v-if="filteredUsers.length === 0">
              <td colspan="7" class="px-6 py-4 text-center text-gray-500 dark:text-gray-400">
                {{ adminStore.isLoading ? 'Chargement des utilisateurs...' : 'Aucun utilisateur trouvé' }}
              </td>
            </tr>
            <tr v-for="user in filteredUsers" :key="user?.id || Math.random()">
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center">
                  <div class="flex-shrink-0 h-10 w-10">
                    <div class="h-10 w-10 rounded-full bg-gray-300 dark:bg-gray-600 flex items-center justify-center">
                      <font-awesome-icon icon="user" class="text-gray-500 dark:text-gray-400" />
                    </div>
                  </div>
                  <div class="ml-4">
                    <div class="text-sm font-medium text-gray-900 dark:text-white">
                      {{ user?.username || user?.display_name || 'Utilisateur' }}
                    </div>
                    <div class="text-sm text-gray-500 dark:text-gray-400">
                      {{ user?.metadata?.email || 'Email non disponible' }}
                    </div>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                <div class="flex flex-col">
                  <span class="font-medium">{{ getCountryFlag(user?.country_code) }} {{ user?.country_code || 'N/A' }}</span>
                  <span class="text-xs text-gray-400">{{ user?.language_code?.toUpperCase() || 'EN' }}</span>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ formatDate(user?.created_at) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                <div class="flex flex-col">
                  <span>{{ formatDate(user?.updated_at) }}</span>
                  <span v-if="isRecentlyActive(user?.updated_at)" class="text-xs text-green-600 dark:text-green-400">
                    Récent
                  </span>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                <div class="flex flex-col">
                  <span class="font-medium">{{ getWalletBalance(user) }} points</span>
                  <span class="text-xs text-gray-400">{{ user.wallets?.[0]?.currency || 'USD' }}</span>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <div class="flex items-center space-x-2">
                  <span v-if="user?.is_admin" 
                        class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-300">
                    Admin
                  </span>
                  <span :class="isUserActive(user) ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300' : 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300'"
                        class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full">
                    {{ isUserActive(user) ? $t('admin.common.active') : $t('admin.common.inactive') }}
                  </span>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                <div class="flex items-center space-x-2">
                  <button
                    @click="viewUserDetails(user)"
                    class="text-blue-600 hover:text-blue-900 dark:text-blue-400 dark:hover:text-blue-300"
                    :title="$t('admin.common.view')"
                    :disabled="!user"
                  >
                    <font-awesome-icon icon="eye" />
                  </button>
                  <button
                    @click="toggleAdminStatus(user)"
                    :class="user?.is_admin ? 'text-red-600 hover:text-red-900 dark:text-red-400' : 'text-green-600 hover:text-green-900 dark:text-green-400'"
                    :title="user?.is_admin ? $t('admin.users.removeAdmin') : $t('admin.users.makeAdmin')"
                    :disabled="!user"
                  >
                    <font-awesome-icon :icon="user?.is_admin ? 'user-minus' : 'user-plus'" />
                  </button>
                  <button
                    @click="viewUserTransactions(user)"
                    class="text-yellow-600 hover:text-yellow-900 dark:text-yellow-400 dark:hover:text-yellow-300"
                    :title="$t('admin.users.viewTransactions')"
                    :disabled="!user"
                  >
                    <font-awesome-icon icon="coins" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal de détails utilisateur -->
    <UserDetailsModal
      v-if="showUserDetailsModal"
      :user="selectedUser"
      @close="closeUserDetailsModal"
    />

    <!-- Modal des transactions -->
    <UserTransactionsModal
      v-if="showTransactionsModal"
      :user="selectedUser"
      @close="closeTransactionsModal"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAdminStore } from '@/stores/admin'
import { useI18n } from 'vue-i18n'
import UserDetailsModal from './modals/UserDetailsModal.vue'
import UserTransactionsModal from './modals/UserTransactionsModal.vue'

const { t } = useI18n()
const adminStore = useAdminStore()

// État local
const userFilter = ref('all')
const searchQuery = ref('')
const showUserDetailsModal = ref(false)
const showTransactionsModal = ref(false)
const selectedUser = ref(null)

// Computed
const filteredUsers = computed(() => {
  let users = adminStore.users
  
  // Filtrer par type d'utilisateur
  if (userFilter.value === 'admin') {
    users = users.filter(user => user.is_admin)
  }
  
  // Filtrer par recherche
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    users = users.filter(user => 
      user.email?.toLowerCase().includes(query) ||
      user.username?.toLowerCase().includes(query) ||
      user.display_name?.toLowerCase().includes(query)
    )
  }
  
  return users
})

const adminUsers = computed(() => {
  return adminStore.users.filter(user => user.is_admin)
})

const activeUsers = computed(() => {
  const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000)
  return adminStore.users.filter(user => 
    user.updated_at && new Date(user.updated_at) > thirtyDaysAgo
  )
})

const totalRevenue = computed(() => {
  return adminStore.totalRevenue || 0
})

// Methods
function formatDate(dateString) {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString('fr-FR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric'
  })
}

function formatCurrency(amount) {
  return new Intl.NumberFormat('fr-FR', {
    style: 'currency',
    currency: 'EUR'
  }).format(amount)
}

function getCountryFlag(countryCode) {
  if (!countryCode) return '🌍'
  
  // Convert country code to flag emoji
  const flagMap = {
    'US': '🇺🇸', 'CI': '🇨🇮', 'FR': '🇫🇷', 'CA': '🇨🇦', 
    'GB': '🇬🇧', 'DE': '🇩🇪', 'JP': '🇯🇵', 'BR': '🇧🇷', 'IN': '🇮🇳'
  }
  
  return flagMap[countryCode] || '🌍'
}

function isRecentlyActive(dateString) {
  if (!dateString) return false
  const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
  return new Date(dateString) > sevenDaysAgo
}

function isUserActive(user) {
  // User is considered active if they've been updated recently (proxy for activity)
  // or if they have recent transactions
  return isRecentlyActive(user.updated_at)
}

function getWalletBalance(user) {
  if (!user?.wallets || !Array.isArray(user.wallets) || user.wallets.length === 0) {
    return 0
  }
  
  const wallet = user.wallets[0]
  return wallet?.balance || 0
}

function viewUserDetails(user) {
  selectedUser.value = user
  showUserDetailsModal.value = true
}

function closeUserDetailsModal() {
  showUserDetailsModal.value = false
  selectedUser.value = null
}

function viewUserTransactions(user) {
  selectedUser.value = user
  showTransactionsModal.value = true
}

function closeTransactionsModal() {
  showTransactionsModal.value = false
  selectedUser.value = null
}

async function toggleAdminStatus(user) {
  const action = user.is_admin ? 'rétrograder' : 'promouvoir'
  if (confirm(`Êtes-vous sûr de vouloir ${action} cet utilisateur ?`)) {
    try {
      await adminStore.updateUserStatus(user.id, { is_admin: !user.is_admin })
    } catch (error) {
      console.error('Erreur lors de la modification du statut admin:', error)
    }
  }
}

// Nouvelles fonctions pour les statistiques améliorées
async function refreshUserStats() {
  try {
    const stats = await adminStore.fetchUserStatistics()
    if (stats) {
      console.log('Statistiques utilisateur:', stats)
      // Ici on pourrait afficher les statistiques dans un modal ou une section dédiée
    }
  } catch (error) {
    console.error('Erreur lors du chargement des statistiques:', error)
  }
}

// Lifecycle
onMounted(async () => {
  try {
    // Essayer d'abord la méthode normale
    await adminStore.fetchUsers()
    
    // Si aucun wallet n'est trouvé, essayer la méthode alternative
    const hasWallets = adminStore.users.some(user => user.wallets && user.wallets.length > 0)
    
    if (!hasWallets) {
      await adminStore.fetchUsersWithWallets()
    }
    
    // Charger aussi les transactions
    await adminStore.fetchWalletTransactions()
  } catch (error) {
    console.error('Erreur lors du chargement des données utilisateur:', error)
  }
})
</script>