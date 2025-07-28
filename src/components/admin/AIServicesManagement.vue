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
            <tr v-for="category in adminStore.serviceCategories" :key="category.id">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">
                {{ category.name }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                <font-awesome-icon :icon="category.icon" class="text-lg" />
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ category.display_order }}
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

    <!-- Gestion des Sous-catégories -->
    <div v-if="activeServiceTab === 'subcategories'" class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
      <div class="flex items-center justify-between mb-6">
        <h3 class="text-lg font-medium text-gray-900 dark:text-white">
          {{ $t('admin.services.subcategories') }}
        </h3>
        <button
          @click="openSubcategoryModal()"
          class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors flex items-center"
        >
          <font-awesome-icon icon="plus" class="mr-2" />
          {{ $t('admin.services.addSubcategory') }}
        </button>
      </div>

      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
          <thead class="bg-gray-50 dark:bg-gray-700">
            <tr>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Nom
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Catégorie
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                Type de transformation
              </th>
              <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                {{ $t('admin.common.actions') }}
              </th>
            </tr>
          </thead>
          <tbody class="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
            <tr v-for="subcategory in adminStore.serviceSubcategories" :key="subcategory.id">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900 dark:text-white">
                {{ subcategory.name }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ subcategory.service_categories?.name }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-300">
                {{ subcategory.from_type }} → {{ subcategory.to_type }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                <button
                  @click="openSubcategoryModal(subcategory)"
                  class="text-blue-600 hover:text-blue-900 dark:text-blue-400 dark:hover:text-blue-300"
                >
                  <font-awesome-icon icon="edit" />
                </button>
                <button
                  @click="deleteSubcategory(subcategory)"
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
                Sous-catégorie
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
            <tr v-for="service in adminStore.aiServices" :key="service.id">
              <td class="px-6 py-4 whitespace-nowrap">
                <div>
                  <div class="text-sm font-medium text-gray-900 dark:text-white">
                    {{ service.display_name || service.name }}
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
                {{ service.service_subcategories?.name }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span :class="service.is_active ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300' : 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300'"
                      class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full">
                  {{ service.is_active ? $t('admin.common.active') : $t('admin.common.inactive') }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span v-if="service.is_new && isNewBadgeActive(service.new_badge_until)"
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

    <SubcategoryModal
      v-if="showSubcategoryModal"
      :subcategory="selectedSubcategory"
      :categories="adminStore.serviceCategories"
      @close="closeSubcategoryModal"
      @save="saveSubcategory"
    />

    <ServiceModal
      v-if="showServiceModal"
      :service="selectedService"
      :subcategories="adminStore.serviceSubcategories"
      @close="closeServiceModal"
      @save="saveService"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAdminStore } from '@/stores/admin'
import { useI18n } from 'vue-i18n'

// Composants modaux
import CategoryModal from './modals/CategoryModal.vue'
import SubcategoryModal from './modals/SubcategoryModal.vue'
import ServiceModal from './modals/ServiceModal.vue'

const { t } = useI18n()
const adminStore = useAdminStore()

// État local
const activeServiceTab = ref('categories')
const showCategoryModal = ref(false)
const showSubcategoryModal = ref(false)
const showServiceModal = ref(false)
const selectedCategory = ref(null)
const selectedSubcategory = ref(null)
const selectedService = ref(null)

// Configuration des onglets
const serviceTabs = [
  { id: 'categories', label: 'admin.services.categories' },
  { id: 'subcategories', label: 'admin.services.subcategories' },
  { id: 'services', label: 'admin.services.services' }
]

// Methods
function isNewBadgeActive(badgeUntil) {
  if (!badgeUntil) return false
  return new Date(badgeUntil) > new Date()
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
      await adminStore.updateServiceCategory(selectedCategory.value.id, categoryData)
    } else {
      await adminStore.createServiceCategory(categoryData)
    }
    closeCategoryModal()
  } catch (error) {
    console.error('Erreur lors de la sauvegarde de la catégorie:', error)
  }
}

async function deleteCategory(category) {
  if (confirm(t('admin.services.confirmDelete'))) {
    try {
      await adminStore.deleteServiceCategory(category.id)
    } catch (error) {
      console.error('Erreur lors de la suppression de la catégorie:', error)
    }
  }
}

// Gestion des sous-catégories
function openSubcategoryModal(subcategory = null) {
  selectedSubcategory.value = subcategory
  showSubcategoryModal.value = true
}

function closeSubcategoryModal() {
  showSubcategoryModal.value = false
  selectedSubcategory.value = null
}

async function saveSubcategory(subcategoryData) {
  try {
    if (selectedSubcategory.value) {
      await adminStore.updateServiceSubcategory(selectedSubcategory.value.id, subcategoryData)
    } else {
      await adminStore.createServiceSubcategory(subcategoryData)
    }
    closeSubcategoryModal()
  } catch (error) {
    console.error('Erreur lors de la sauvegarde de la sous-catégorie:', error)
  }
}

async function deleteSubcategory(subcategory) {
  if (confirm(t('admin.services.confirmDelete'))) {
    try {
      await adminStore.deleteServiceSubcategory(subcategory.id)
    } catch (error) {
      console.error('Erreur lors de la suppression de la sous-catégorie:', error)
    }
  }
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
      await adminStore.updateAiService(selectedService.value.id, serviceData)
    } else {
      await adminStore.createAiService(serviceData)
    }
    closeServiceModal()
  } catch (error) {
    console.error('Erreur lors de la sauvegarde du service:', error)
  }
}

async function deleteService(service) {
  if (confirm(t('admin.services.confirmDelete'))) {
    try {
      await adminStore.deleteAiService(service.id)
    } catch (error) {
      console.error('Erreur lors de la suppression du service:', error)
    }
  }
}

// Lifecycle
onMounted(async () => {
  await Promise.all([
    adminStore.fetchServiceCategories(),
    adminStore.fetchServiceSubcategories(),
    adminStore.fetchAiServices()
  ])
})
</script>