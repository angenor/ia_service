<template>
  <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
    <div class="relative top-10 mx-auto p-5 border w-full max-w-4xl shadow-lg rounded-md bg-white dark:bg-gray-800">
      <div class="mt-3">
        <!-- En-tête -->
        <div class="flex items-center justify-between mb-6">
          <h3 class="text-lg font-medium text-gray-900 dark:text-white">
            {{ $t('admin.users.viewTransactions') }} - {{ user.email }}
          </h3>
          <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300">
            <font-awesome-icon icon="times" />
          </button>
        </div>

        <!-- Résumé du wallet -->
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <div class="bg-blue-50 dark:bg-blue-900/20 p-4 rounded-lg">
            <div class="text-2xl font-bold text-blue-600 dark:text-blue-400">{{ user.wallets?.[0]?.balance || 0 }}</div>
            <div class="text-sm text-blue-600 dark:text-blue-400">Solde actuel</div>
          </div>
          <div class="bg-green-50 dark:bg-green-900/20 p-4 rounded-lg">
            <div class="text-2xl font-bold text-green-600 dark:text-green-400">{{ totalRecharges }}</div>
            <div class="text-sm text-green-600 dark:text-green-400">Total rechargé</div>
          </div>
          <div class="bg-red-50 dark:bg-red-900/20 p-4 rounded-lg">
            <div class="text-2xl font-bold text-red-600 dark:text-red-400">{{ totalSpent }}</div>
            <div class="text-sm text-red-600 dark:text-red-400">Total dépensé</div>
          </div>
          <div class="bg-yellow-50 dark:bg-yellow-900/20 p-4 rounded-lg">
            <div class="text-2xl font-bold text-yellow-600 dark:text-yellow-400">{{ totalTransactions }}</div>
            <div class="text-sm text-yellow-600 dark:text-yellow-400">Transactions</div>
          </div>
        </div>

        <!-- Filtres -->
        <div class="flex items-center space-x-4 mb-6">
          <select 
            v-model="filterType"
            class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
          >
            <option value="">Tous les types</option>
            <option value="purchase">Achats</option>
            <option value="recharge">Recharges</option>
            <option value="refund">Remboursements</option>
            <option value="bonus">Bonus</option>
          </select>
          
          <input
            v-model="dateFrom"
            type="date"
            class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
          >
          
          <input
            v-model="dateTo"
            type="date"
            class="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
          >
          
          <button
            @click="exportTransactions"
            class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors"
          >
            <font-awesome-icon icon="download" class="mr-2" />
            Exporter
          </button>
        </div>

        <!-- Tableau des transactions -->
        <div class="overflow-x-auto max-h-96">
          <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead class="bg-gray-50 dark:bg-gray-700 sticky top-0">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Date
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Type
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Montant
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Description
                </th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                  Statut
                </th>
              </tr>
            </thead>
            <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
              <tr v-for="transaction in filteredTransactions" :key="transaction.id">
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                  {{ formatDate(transaction.created_at) }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span :class="getTypeClass(transaction.type)" class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full">
                    {{ getTypeLabel(transaction.type) }}
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <span :class="transaction.amount > 0 ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'">
                    {{ transaction.amount > 0 ? '+' : '' }}{{ transaction.amount }} points
                  </span>
                </td>
                <td class="px-6 py-4 text-sm text-gray-900 dark:text-white">
                  {{ transaction.description || transaction.metadata?.service_name || 'N/A' }}
                </td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span :class="getStatusClass(transaction.status)" class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full">
                    {{ transaction.status }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Pagination simulée -->
        <div class="mt-4 flex items-center justify-between">
          <div class="text-sm text-gray-700 dark:text-gray-300">
            Affichage de {{ filteredTransactions.length }} transactions
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

const emit = defineEmits(['close'])

// Filtres
const filterType = ref('')
const dateFrom = ref('')
const dateTo = ref('')

// Données simulées
const transactions = ref([])

// Computed
const filteredTransactions = computed(() => {
  let filtered = transactions.value
  
  if (filterType.value) {
    filtered = filtered.filter(t => t.type === filterType.value)
  }
  
  if (dateFrom.value) {
    filtered = filtered.filter(t => new Date(t.created_at) >= new Date(dateFrom.value))
  }
  
  if (dateTo.value) {
    filtered = filtered.filter(t => new Date(t.created_at) <= new Date(dateTo.value))
  }
  
  return filtered.sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
})

const totalRecharges = computed(() => {
  return transactions.value
    .filter(t => t.type === 'recharge' && t.amount > 0)
    .reduce((sum, t) => sum + t.amount, 0)
})

const totalSpent = computed(() => {
  return Math.abs(transactions.value
    .filter(t => t.type === 'purchase' && t.amount < 0)
    .reduce((sum, t) => sum + t.amount, 0))
})

const totalTransactions = computed(() => transactions.value.length)

// Methods
function formatDate(dateString) {
  return new Date(dateString).toLocaleString('fr-FR')
}

function getTypeClass(type) {
  switch (type) {
    case 'recharge':
      return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300'
    case 'purchase':
      return 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300'
    case 'refund':
      return 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300'
    case 'bonus':
      return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300'
    default:
      return 'bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-300'
  }
}

function getTypeLabel(type) {
  const labels = {
    'recharge': 'Recharge',
    'purchase': 'Achat',
    'refund': 'Remboursement',
    'bonus': 'Bonus'
  }
  return labels[type] || type
}

function getStatusClass(status) {
  switch (status) {
    case 'completed':
      return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300'
    case 'pending':
      return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300'
    case 'failed':
      return 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300'
    default:
      return 'bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-300'
  }
}

function exportTransactions() {
  const data = {
    user: {
      id: props.user.id,
      email: props.user.email
    },
    transactions: filteredTransactions.value,
    summary: {
      totalRecharges: totalRecharges.value,
      totalSpent: totalSpent.value,
      totalTransactions: totalTransactions.value,
      currentBalance: props.user.wallets?.[0]?.balance || 0
    },
    exportedAt: new Date().toISOString()
  }
  
  const blob = new Blob([JSON.stringify(data, null, 2)], {
    type: 'application/json'
  })
  
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `transactions-${props.user.email}-${new Date().toISOString().split('T')[0]}.json`
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

// Générer des données simulées
function generateMockTransactions() {
  const types = ['recharge', 'purchase', 'refund', 'bonus']
  const statuses = ['completed', 'pending', 'failed']
  const services = ['GPT-4 Chat', 'DALL-E Image', 'Claude Sonnet', 'Stable Video', 'ElevenLabs Voice']
  
  const mockTransactions = []
  
  for (let i = 0; i < 50; i++) {
    const type = types[Math.floor(Math.random() * types.length)]
    const isPositive = type === 'recharge' || type === 'bonus' || type === 'refund'
    
    mockTransactions.push({
      id: i + 1,
      type,
      amount: isPositive ? 
        Math.floor(Math.random() * 1000) + 100 : 
        -(Math.floor(Math.random() * 50) + 5),
      description: type === 'purchase' ? 
        `Utilisation de ${services[Math.floor(Math.random() * services.length)]}` :
        type === 'recharge' ? 'Recharge du wallet' :
        type === 'bonus' ? 'Bonus de bienvenue' :
        'Remboursement',
      status: statuses[Math.floor(Math.random() * statuses.length)],
      created_at: new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000).toISOString(),
      metadata: type === 'purchase' ? {
        service_name: services[Math.floor(Math.random() * services.length)]
      } : {}
    })
  }
  
  transactions.value = mockTransactions
}

onMounted(() => {
  generateMockTransactions()
})
</script>