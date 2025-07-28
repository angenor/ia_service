<template>
  <div class="space-y-6">
    <!-- En-tête -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <div class="flex items-center justify-between">
        <h2 class="text-xl font-semibold text-gray-900 dark:text-white">
          {{ $t('admin.promotions.title') }}
        </h2>
        <button
          @click="openPromotionModal()"
          class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors flex items-center"
        >
          <font-awesome-icon icon="plus" class="mr-2" />
          {{ $t('admin.promotions.addPromotion') }}
        </button>
      </div>
    </div>

    <!-- Onglets -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <nav class="flex space-x-8" aria-label="Tabs">
        <button
          @click="activeTab = 'active'"
          :class="[
            'whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm',
            activeTab === 'active'
              ? 'border-blue-500 text-blue-600 dark:text-blue-400'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 dark:text-gray-400 dark:hover:text-gray-300'
          ]"
        >
          {{ $t('admin.promotions.activePromotions') }}
        </button>
        <button
          @click="activeTab = 'expired'"
          :class="[
            'whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm',
            activeTab === 'expired'
              ? 'border-blue-500 text-blue-600 dark:text-blue-400'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 dark:text-gray-400 dark:hover:text-gray-300'
          ]"
        >
          {{ $t('admin.promotions.expiredPromotions') }}
        </button>
      </nav>

      <!-- Tableau des promotions -->
      <div class="mt-6 overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-700">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.promotions.promoCode') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Type/Valeur
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Période
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Utilisation
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.common.actions') }}
              </th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
            <tr v-for="promotion in filteredPromotions" :key="promotion.id">
              <td class="px-6 py-4 whitespace-nowrap">
                <div>
                  <div class="text-sm font-medium text-gray-900 dark:text-white">
                    {{ promotion.code }}
                  </div>
                  <div class="text-sm text-gray-500 dark:text-gray-400">
                    {{ promotion.description }}
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                <span v-if="promotion.discount_type === 'percentage'" class="text-green-600">
                  {{ promotion.discount_value }}%
                </span>
                <span v-else class="text-blue-600">
                  {{ promotion.discount_value }} points
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                <div>
                  <div>{{ formatDate(promotion.valid_from) }}</div>
                  <div>{{ formatDate(promotion.valid_until) }}</div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ promotion.current_usage || 0 }} / {{ promotion.max_usage || '∞' }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                <button
                  @click="openPromotionModal(promotion)"
                  class="text-blue-600 hover:text-blue-900 dark:text-blue-400 dark:hover:text-blue-300"
                >
                  <font-awesome-icon icon="edit" />
                </button>
                <button
                  @click="deletePromotion(promotion)"
                  class="text-red-600 hover:text-red-900 dark:text-red-400 dark:hover:text-red-300"
                >
                  <font-awesome-icon icon="trash" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal de promotion -->
    <PromotionModal
      v-if="showPromotionModal"
      :promotion="selectedPromotion"
      :services="adminStore.aiServices"
      @close="closePromotionModal"
      @save="savePromotion"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAdminStore } from '@/stores/admin'
import { useI18n } from 'vue-i18n'
import PromotionModal from './modals/PromotionModal.vue'

const { t } = useI18n()
const adminStore = useAdminStore()

// État local
const activeTab = ref('active')
const showPromotionModal = ref(false)
const selectedPromotion = ref(null)

// Computed
const filteredPromotions = computed(() => {
  const now = new Date()
  return adminStore.promotions.filter(promotion => {
    if (activeTab.value === 'active') {
      return new Date(promotion.valid_until) > now
    } else {
      return new Date(promotion.valid_until) <= now
    }
  })
})

// Methods
function formatDate(dateString) {
  return new Date(dateString).toLocaleDateString('fr-FR')
}

function openPromotionModal(promotion = null) {
  selectedPromotion.value = promotion
  showPromotionModal.value = true
}

function closePromotionModal() {
  showPromotionModal.value = false
  selectedPromotion.value = null
}

async function savePromotion(promotionData) {
  try {
    if (selectedPromotion.value) {
      await adminStore.updatePromotion(selectedPromotion.value.id, promotionData)
    } else {
      await adminStore.createPromotion(promotionData)
    }
    closePromotionModal()
  } catch (error) {
    console.error('Erreur lors de la sauvegarde de la promotion:', error)
  }
}

async function deletePromotion(promotion) {
  if (confirm(t('admin.services.confirmDelete'))) {
    try {
      await adminStore.deletePromotion(promotion.id)
    } catch (error) {
      console.error('Erreur lors de la suppression de la promotion:', error)
    }
  }
}

// Lifecycle
onMounted(async () => {
  await Promise.all([
    adminStore.fetchPromotions(),
    adminStore.fetchAiServices()
  ])
})
</script>