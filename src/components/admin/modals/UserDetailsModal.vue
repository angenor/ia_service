<template>
  <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
    <div class="relative top-10 mx-auto p-5 border w-full max-w-3xl shadow-lg rounded-md bg-white dark:bg-gray-800">
      <div class="mt-3">
        <!-- En-tête -->
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-lg font-medium text-gray-900 dark:text-white">
            {{ $t('admin.users.userProfile') }}
          </h3>
          <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300">
            <font-awesome-icon icon="times" />
          </button>
        </div>

        <!-- Informations utilisateur -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <!-- Profil utilisateur -->
          <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-6">
            <h4 class="text-md font-medium text-gray-900 dark:text-white mb-4">
              Informations personnelles
            </h4>
            
            <div class="space-y-3">
              <div class="flex items-center">
                <div class="w-16 h-16 rounded-full bg-gray-300 dark:bg-gray-600 flex items-center justify-center mr-4">
                  <font-awesome-icon icon="user" class="text-2xl text-gray-500 dark:text-gray-400" />
                </div>
                <div>
                  <h5 class="text-lg font-medium text-gray-900 dark:text-white">
                    {{ user.username || user.display_name || 'Utilisateur' }}
                  </h5>
                  <p class="text-sm text-gray-500 dark:text-gray-400">{{ user.email }}</p>
                </div>
              </div>

              <div class="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <span class="font-medium text-gray-700 dark:text-gray-300">ID:</span>
                  <span class="text-gray-500 dark:text-gray-400 ml-1">{{ user.id }}</span>
                </div>
                <div>
                  <span class="font-medium text-gray-700 dark:text-gray-300">Pays:</span>
                  <span class="text-gray-500 dark:text-gray-400 ml-1">{{ user.country || 'N/A' }}</span>
                </div>
                <div>
                  <span class="font-medium text-gray-700 dark:text-gray-300">Langue:</span>
                  <span class="text-gray-500 dark:text-gray-400 ml-1">{{ user.language || 'N/A' }}</span>
                </div>
                <div>
                  <span class="font-medium text-gray-700 dark:text-gray-300">Provider:</span>
                  <span class="text-gray-500 dark:text-gray-400 ml-1">{{ user.provider || 'Email' }}</span>
                </div>
              </div>

              <div class="flex items-center space-x-4 pt-2">
                <span v-if="user.is_admin" 
                      class="px-2 py-1 text-xs font-semibold rounded-full bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-300">
                  Administrateur
                </span>
                <span :class="user.is_active ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300' : 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300'"
                      class="px-2 py-1 text-xs font-semibold rounded-full">
                  {{ user.is_active ? 'Actif' : 'Inactif' }}
                </span>
              </div>
            </div>
          </div>

          <!-- Informations du wallet -->
          <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-6">
            <h4 class="text-md font-medium text-gray-900 dark:text-white mb-4">
              Portefeuille
            </h4>
            
            <div class="space-y-3">
              <div class="text-center p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
                <div class="text-2xl font-bold text-blue-600 dark:text-blue-400">
                  {{ user.wallets?.[0]?.balance || 0 }}
                </div>
                <div class="text-sm text-blue-600 dark:text-blue-400">Points disponibles</div>
              </div>

              <div class="grid grid-cols-2 gap-4 text-sm">
                <div class="text-center p-3 bg-green-50 dark:bg-green-900/20 rounded">
                  <div class="font-bold text-green-600 dark:text-green-400">{{ userStats.totalSpent || 0 }}</div>
                  <div class="text-green-600 dark:text-green-400">Total dépensé</div>
                </div>
                <div class="text-center p-3 bg-yellow-50 dark:bg-yellow-900/20 rounded">
                  <div class="font-bold text-yellow-600 dark:text-yellow-400">{{ userStats.totalRecharge || 0 }}</div>
                  <div class="text-yellow-600 dark:text-yellow-400">Total rechargé</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Statistiques d'utilisation -->
        <div class="mt-6 bg-gray-50 dark:bg-gray-700 rounded-lg p-6">
          <h4 class="text-md font-medium text-gray-900 dark:text-white mb-4">
            {{ $t('admin.users.userStats') }}
          </h4>
          
          <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div class="text-center">
              <div class="text-xl font-bold text-gray-900 dark:text-white">{{ userStats.totalUsage || 0 }}</div>
              <div class="text-sm text-gray-500 dark:text-gray-400">Utilisations totales</div>
            </div>
            <div class="text-center">
              <div class="text-xl font-bold text-gray-900 dark:text-white">{{ userStats.servicesUsed || 0 }}</div>
              <div class="text-sm text-gray-500 dark:text-gray-400">{{ $t('admin.users.servicesUsed') }}</div>
            </div>
            <div class="text-center">
              <div class="text-xl font-bold text-gray-900 dark:text-white">{{ userStats.averageUsage || 0 }}</div>
              <div class="text-sm text-gray-500 dark:text-gray-400">{{ $t('admin.users.averageUsage') }}</div>
            </div>
            <div class="text-center">
              <div class="text-xl font-bold text-gray-900 dark:text-white">{{ formatDate(user.last_login) }}</div>
              <div class="text-sm text-gray-500 dark:text-gray-400">{{ $t('admin.users.lastLogin') }}</div>
            </div>
          </div>
        </div>

        <!-- Services les plus utilisés -->
        <div class="mt-6 bg-gray-50 dark:bg-gray-700 rounded-lg p-6">
          <h4 class="text-md font-medium text-gray-900 dark:text-white mb-4">
            Services favoris
          </h4>
          
          <div v-if="favoriteServices.length === 0" class="text-center py-4 text-gray-500 dark:text-gray-400">
            Aucune utilisation enregistrée
          </div>
          
          <div v-else class="space-y-2">
            <div v-for="service in favoriteServices" :key="service.id" 
                 class="flex items-center justify-between p-3 bg-white dark:bg-gray-600 rounded">
              <span class="text-sm font-medium text-gray-900 dark:text-white">{{ service.name }}</span>
              <div class="text-right">
                <div class="text-sm font-bold text-gray-900 dark:text-white">{{ service.usage_count }}</div>
                <div class="text-xs text-gray-500 dark:text-gray-400">utilisations</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Informations de compte -->
        <div class="mt-6 bg-gray-50 dark:bg-gray-700 rounded-lg p-6">
          <h4 class="text-md font-medium text-gray-900 dark:text-white mb-4">
            Informations du compte
          </h4>
          
          <div class="grid grid-cols-2 gap-4 text-sm">
            <div>
              <span class="font-medium text-gray-700 dark:text-gray-300">{{ $t('admin.users.registrationDate') }}:</span>
              <div class="text-gray-500 dark:text-gray-400">{{ formatDate(user.created_at) }}</div>
            </div>
            <div>
              <span class="font-medium text-gray-700 dark:text-gray-300">Dernière mise à jour:</span>
              <div class="text-gray-500 dark:text-gray-400">{{ formatDate(user.updated_at) }}</div>
            </div>
            <div>
              <span class="font-medium text-gray-700 dark:text-gray-300">Wallet créé:</span>
              <div class="text-gray-500 dark:text-gray-400">{{ formatDate(user.wallets?.[0]?.created_at) }}</div>
            </div>
            <div>
              <span class="font-medium text-gray-700 dark:text-gray-300">Plan:</span>
              <div class="text-gray-500 dark:text-gray-400">{{ user.subscription_plan || 'Gratuit' }}</div>
            </div>
          </div>
        </div>

        <!-- Actions -->
        <div class="mt-6 flex justify-between">
          <div class="space-x-3">
            <button
              @click="viewTransactions"
              class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
            >
              <font-awesome-icon icon="coins" class="mr-2" />
              {{ $t('admin.users.viewTransactions') }}
            </button>
            <button
              @click="viewUsageHistory"
              class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors"
            >
              <font-awesome-icon icon="chart-line" class="mr-2" />
              {{ $t('admin.users.viewUsage') }}
            </button>
          </div>
          
          <button
            @click="$emit('close')"
            class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700"
          >
            Fermer
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const props = defineProps({
  user: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['close', 'viewTransactions', 'viewUsage'])

// Données simulées pour les statistiques
const userStats = ref({
  totalSpent: 2450,
  totalRecharge: 3000,
  totalUsage: 156,
  servicesUsed: 8,
  averageUsage: 12
})

const favoriteServices = ref([
  { id: 1, name: 'GPT-4 Chat', usage_count: 45 },
  { id: 2, name: 'DALL-E Image', usage_count: 23 },
  { id: 3, name: 'Claude Sonnet', usage_count: 18 },
  { id: 4, name: 'Stable Video', usage_count: 12 },
  { id: 5, name: 'ElevenLabs Voice', usage_count: 8 }
])

function formatDate(dateString) {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString('fr-FR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function viewTransactions() {
  emit('viewTransactions', props.user)
}

function viewUsageHistory() {
  emit('viewUsage', props.user)
}

onMounted(() => {
  // Charger les statistiques réelles de l'utilisateur si nécessaire
})
</script>