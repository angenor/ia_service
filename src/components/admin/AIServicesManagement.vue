<template>
  <div class="space-y-6">
    <!-- Navigation par onglets -->
    <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <nav class="flex space-x-8" aria-label="Tabs">
        <button
          v-for="tab in serviceTabs"
          :key="tab.id"
          @click="activeServiceTab = tab.id"
          :class="[
            'whitespace-nowrap py-2 px-1 border-b-2 font-medium text-sm',
            activeServiceTab === tab.id
              ? 'border-blue-500 text-blue-600 dark:text-blue-400'
              : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300 dark:text-gray-400 dark:hover:text-gray-300'
          ]"
        >
          {{ $t(tab.label) }}
        </button>
      </nav>
    </div>

    <!-- Gestion des Catégories -->
    <div v-if="activeServiceTab === 'categories'" class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <div class="flex items-center justify-between mb-6">
        <h3 class="text-lg font-medium text-gray-900 dark:text-white">
          {{ $t('admin.services.categories') }}
        </h3>
        <button
          @click="openCategoryModal()"
          class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors flex items-center"
        >
          <font-awesome-icon icon="plus" class="mr-2" />
          {{ $t('admin.services.addCategory') }}
        </button>
      </div>

      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-700">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.services.categoryName') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.services.categoryIcon') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.services.categoryOrder') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.services.isActive') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.common.actions') }}
              </th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
            <tr v-for="category in aiServicesStore.categories" :key="category.id">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">
                {{ category.name }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                <font-awesome-icon 
                  :icon="getValidIcon(category.icon)" 
                  class="text-lg" 
                  v-if="getValidIcon(category.icon)"
                />
                <span v-else class="text-gray-400 italic">Aucune icône</span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ category.sort_order }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span :class="category.is_active ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300' : 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300'"
                      class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full">
                  {{ category.is_active ? $t('admin.common.active') : $t('admin.common.inactive') }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                <button
                  @click="openCategoryModal(category)"
                  class="text-blue-600 hover:text-blue-900 dark:text-blue-400 dark:hover:text-blue-300"
                >
                  <font-awesome-icon icon="edit" />
                </button>
                <button
                  @click="deleteCategory(category)"
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

    <!-- Gestion des Capacités -->
    <div v-if="activeServiceTab === 'abilities'" class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <div class="flex items-center justify-between mb-6">
        <h3 class="text-lg font-medium text-gray-900 dark:text-white">
          {{ $t('admin.services.abilities') }}
        </h3>
        <button
          @click="openAbilityModal()"
          class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors flex items-center"
        >
          <font-awesome-icon icon="plus" class="mr-2" />
          {{ $t('admin.services.addAbility') }}
        </button>
      </div>

      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-700">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.services.abilityName') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.services.category') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.services.transformation') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.services.modelsCount') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.services.isActive') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.common.actions') }}
              </th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
            <tr v-for="ability in aiServicesStore.abilities" :key="ability.id">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">
                {{ ability.name }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ ability.service_categories?.name }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                <span v-if="ability.from_type && ability.to_type" class="flex items-center">
                  <span class="text-gray-600 dark:text-gray-400">{{ ability.from_type }}</span>
                  <font-awesome-icon icon="arrow-right" class="mx-2 text-xs text-gray-400" />
                  <span class="text-gray-600 dark:text-gray-400">{{ ability.to_type }}</span>
                </span>
                <span v-else class="text-gray-400 italic">—</span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ getAbilityModelsCount(ability.id) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span :class="ability.is_active ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300' : 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300'"
                      class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full">
                  {{ ability.is_active ? $t('admin.common.active') : $t('admin.common.inactive') }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                <button
                  @click="openAbilityModal(ability)"
                  class="text-blue-600 hover:text-blue-900 dark:text-blue-400 dark:hover:text-blue-300"
                  :title="$t('admin.common.edit')"
                >
                  <font-awesome-icon icon="edit" />
                </button>
                <button
                  @click="manageAbilityModels(ability)"
                  class="text-green-600 hover:text-green-900 dark:text-green-400 dark:hover:text-green-300"
                  :title="$t('admin.services.manageModels')"
                >
                  <font-awesome-icon icon="cogs" />
                </button>
                <button
                  @click="deleteAbility(ability)"
                  class="text-red-600 hover:text-red-900 dark:text-red-400 dark:hover:text-red-300"
                  :title="$t('admin.common.delete')"
                >
                  <font-awesome-icon icon="trash" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Gestion des Services -->
    <div v-if="activeServiceTab === 'services'" class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <div class="flex items-center justify-between mb-6">
        <h3 class="text-lg font-medium text-gray-900 dark:text-white">
          {{ $t('admin.services.services') }}
        </h3>
        <button
          @click="openServiceModal()"
          class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors flex items-center"
        >
          <font-awesome-icon icon="plus" class="mr-2" />
          {{ $t('admin.services.addService') }}
        </button>
      </div>

      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-700">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.services.serviceName') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.services.serviceProvider') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.services.category') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.services.abilities') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.services.isActive') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.services.isNew') }}
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.common.actions') }}
              </th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
            <tr v-for="service in aiServicesStore.services" :key="service.id">
              <td class="px-6 py-4 whitespace-nowrap">
                <div>
                  <div class="text-sm font-medium text-gray-900 dark:text-white">
                    {{ service.name }}
                  </div>
                  <div class="text-sm text-gray-500 dark:text-gray-400">
                    {{ service.description }}
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ service.provider }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ service.service_categories?.name }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                <div class="flex flex-wrap gap-1">
                  <span v-for="ability in getServiceAbilities(service.id)" :key="ability.id"
                        class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300">
                    {{ ability.name }}
                  </span>
                  <button
                    @click="manageServiceAbilities(service)"
                    class="ml-1 text-blue-600 hover:text-blue-900 dark:text-blue-400 dark:hover:text-blue-300"
                    :title="$t('admin.services.manageAbilities')"
                  >
                    <font-awesome-icon icon="plus-circle" class="text-xs" />
                  </button>
                </div>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span :class="service.is_active ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300' : 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300'"
                      class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full">
                  {{ service.is_active ? $t('admin.common.active') : $t('admin.common.inactive') }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span v-if="service.is_new && isNewBadgeActive(service.new_until)"
                      class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300">
                  Nouveau
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                <button
                  @click="openServiceModal(service)"
                  class="text-blue-600 hover:text-blue-900 dark:text-blue-400 dark:hover:text-blue-300"
                >
                  <font-awesome-icon icon="edit" />
                </button>
                <button
                  @click="deleteService(service)"
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

    <!-- Modals -->
    <CategoryModal
      v-if="showCategoryModal"
      :category="selectedCategory"
      @close="closeCategoryModal"
      @save="saveCategory"
    />

    <AbilityModal
      v-if="showAbilityModal"
      :ability="selectedAbility"
      :categories="aiServicesStore.categories"
      @close="closeAbilityModal"
      @save="saveAbility"
    />

    <ServiceModal
      v-if="showServiceModal"
      :service="selectedService"
      :categories="aiServicesStore.categories"
      @close="closeServiceModal"
      @save="saveService"
    />

    <ServiceAbilitiesModal
      v-if="showServiceAbilitiesModal"
      :service="selectedService"
      :abilities="aiServicesStore.abilities"
      :serviceAbilities="getServiceAbilities(selectedService?.id)"
      @close="closeServiceAbilitiesModal"
      @save="aiServicesStore.updateServiceAbilities"
    />

    <AbilityModelsModal
      v-if="showAbilityModelsModal"
      :ability="selectedAbility"
      :services="aiServicesStore.services"
      @close="closeAbilityModelsModal"
      @save="aiServicesStore.updateAbilityModels"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAIServicesStore } from '@/stores/aiServices'
import { useI18n } from 'vue-i18n'

// Composants modaux
import CategoryModal from './modals/CategoryModal.vue'
import AbilityModal from './modals/AbilityModal.vue'
import ServiceModal from './modals/ServiceModal.vue'
import ServiceAbilitiesModal from './modals/ServiceAbilitiesModal.vue'
import AbilityModelsModal from './modals/AbilityModelsModal.vue'

const { t } = useI18n()
const aiServicesStore = useAIServicesStore()

// État local
const activeServiceTab = ref('categories')
const showCategoryModal = ref(false)
const showAbilityModal = ref(false)
const showServiceModal = ref(false)
const showServiceAbilitiesModal = ref(false)
const showAbilityModelsModal = ref(false)
const selectedCategory = ref(null)
const selectedAbility = ref(null)
const selectedService = ref(null)

// Configuration des onglets
const serviceTabs = [
  { id: 'categories', label: 'admin.services.categories' },
  { id: 'abilities', label: 'admin.services.abilities' },
  { id: 'services', label: 'admin.services.services' }
]

// Methods
function isNewBadgeActive(badgeUntil) {
  if (!badgeUntil) return false
  return new Date(badgeUntil) > new Date()
}

function getValidIcon(iconName) {
  if (!iconName) return null
  // Liste des icônes disponibles dans notre configuration
  const availableIcons = [
    'sun', 'moon', 'globe', 'chevron-up', 'chevron-down', 'chevron-left',
    'home', 'info-circle', 'plus', 'flask', 'cog', 'image', 'music', 'video',
    'tools', 'project-diagram', 'file-pdf', 'book', 'brain', 'star', 'search',
    'coins', 'user', 'arrow-right', 'volume-up', 'microphone', 'magic', 'code',
    'envelope', 'play', 'robot', 'file-video', 'palette', 'wand-magic-sparkles',
    'language', 'eye', 'comments', 'sign-out-alt', 'sign-in-alt', 'times',
    'cloud-upload-alt', 'file', 'camera', 'check-circle', 'laptop', 'chart-line',
    'cogs', 'dollar-sign', 'tags', 'users', 'exclamation-triangle', 'edit',
    'trash', 'download', 'upload', 'sync', 'user-minus', 'user-plus', 'chart-bar',
    'plus-circle'
  ]
  
  return availableIcons.includes(iconName) ? iconName : 'cogs'
}

// Gestion des catégories
function openCategoryModal(category = null) {
  selectedCategory.value = category
  showCategoryModal.value = true
}

function closeCategoryModal() {
  showCategoryModal.value = false
  selectedCategory.value = null
}

async function saveCategory(categoryData) {
  try {
    if (selectedCategory.value) {
      await aiServicesStore.updateCategory(selectedCategory.value.id, categoryData)
    } else {
      await aiServicesStore.createCategory(categoryData)
    }
    closeCategoryModal()
  } catch (error) {
    console.error('Erreur lors de la sauvegarde de la catégorie:', error)
  }
}

async function deleteCategory(category) {
  if (confirm(t('admin.services.confirmDelete'))) {
    try {
      await aiServicesStore.deleteCategory(category.id)
    } catch (error) {
      console.error('Erreur lors de la suppression de la catégorie:', error)
    }
  }
}

// Gestion des capacités
function openAbilityModal(ability = null) {
  selectedAbility.value = ability
  showAbilityModal.value = true
}

function closeAbilityModal() {
  showAbilityModal.value = false
  selectedAbility.value = null
}

async function saveAbility(abilityData) {
  try {
    if (selectedAbility.value) {
      await aiServicesStore.updateAbility(selectedAbility.value.id, abilityData)
    } else {
      await aiServicesStore.createAbility(abilityData)
    }
    closeAbilityModal()
  } catch (error) {
    console.error('Erreur lors de la sauvegarde de la capacité:', error)
  }
}

async function deleteAbility(ability) {
  if (confirm(t('admin.services.confirmDelete'))) {
    try {
      await aiServicesStore.deleteAbility(ability.id)
    } catch (error) {
      console.error('Erreur lors de la suppression de la capacité:', error)
    }
  }
}

// Gestion des associations service-capacité
function manageServiceAbilities(service) {
  selectedService.value = service
  showServiceAbilitiesModal.value = true
}

function closeServiceAbilitiesModal() {
  showServiceAbilitiesModal.value = false
  selectedService.value = null
}

// Gestion des associations capacité-modèles
function manageAbilityModels(ability) {
  selectedAbility.value = ability
  showAbilityModelsModal.value = true
}

function closeAbilityModelsModal() {
  showAbilityModelsModal.value = false
  selectedAbility.value = null
}

// Helpers
function getServiceAbilities(serviceId) {
  return aiServicesStore.getServiceAbilities(serviceId) || []
}

function getAbilityModelsCount(abilityId) {
  return aiServicesStore.getAbilityModelsCount(abilityId) || 0
}

// Gestion des services
function openServiceModal(service = null) {
  selectedService.value = service
  showServiceModal.value = true
}

function closeServiceModal() {
  showServiceModal.value = false
  selectedService.value = null
}

async function saveService(serviceData) {
  try {
    if (selectedService.value) {
      await aiServicesStore.updateService(selectedService.value.id, serviceData)
    } else {
      await aiServicesStore.createService(serviceData)
    }
    closeServiceModal()
  } catch (error) {
    console.error('Erreur lors de la sauvegarde du service:', error)
  }
}

async function deleteService(service) {
  if (confirm(t('admin.services.confirmDelete'))) {
    try {
      await aiServicesStore.deleteService(service.id)
    } catch (error) {
      console.error('Erreur lors de la suppression du service:', error)
    }
  }
}

// Lifecycle
onMounted(async () => {
  await aiServicesStore.fetchAllData()
})
</script>