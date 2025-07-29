<template>
  <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
    <div class="relative top-10 mx-auto p-5 border w-full max-w-2xl shadow-lg rounded-md bg-white dark:bg-gray-800">
      <div class="mt-3">
        <!-- En-tête -->
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-medium text-gray-900 dark:text-white">
            {{ promotion ? $t('admin.promotions.editPromotion') : $t('admin.promotions.addPromotion') }}
          </h3>
          <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300">
            <font-awesome-icon icon="times" />
          </button>
        </div>

        <!-- Formulaire -->
        <form @submit.prevent="handleSubmit" class="space-y-4">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('admin.promotions.promoCode') }}
              </label>
              <input
                v-model="form.code"
                type="text"
                required
                placeholder="WELCOME20"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('admin.promotions.discountType') }}
              </label>
              <select
                v-model="form.discount_type"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
                <option value="percentage">{{ $t('admin.promotions.percentage') }}</option>
                <option value="fixed_points">{{ $t('admin.promotions.fixedPoints') }}</option>
              </select>
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Nom de la promotion
            </label>
            <input
              v-model="form.name"
              type="text"
              required
              placeholder="Ex: Promotion de bienvenue"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            >
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Description
            </label>
            <textarea
              v-model="form.description"
              rows="2"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            ></textarea>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('admin.promotions.discountValue') }}
                <span v-if="form.discount_type === 'percentage'">(%)</span>
                <span v-else>(points)</span>
              </label>
              <input
                v-model.number="form.discount_value"
                type="number"
                :min="form.discount_type === 'percentage' ? 1 : 10"
                :max="form.discount_type === 'percentage' ? 100 : undefined"
                required
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('admin.promotions.minPurchase') }} (points)
              </label>
              <input
                v-model.number="form.min_purchase_points"
                type="number"
                min="0"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Limite d'usage total
              </label>
              <input
                v-model.number="form.max_uses_total"
                type="number"
                min="1"
                placeholder="Illimité si vide"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Limite par utilisateur
              </label>
              <input
                v-model.number="form.max_uses_per_user"
                type="number"
                min="1"
                value="1"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('admin.promotions.validFrom') }}
              </label>
              <input
                v-model="form.valid_from"
                type="datetime-local"
                required
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('admin.promotions.validUntil') }}
              </label>
              <input
                v-model="form.valid_until"
                type="datetime-local"
                required
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              {{ $t('admin.promotions.applicableServices') }}
            </label>
            <div class="max-h-32 overflow-y-auto border border-gray-300 dark:border-gray-600 rounded-md p-2 space-y-1">
              <div class="flex items-center">
                <input
                  v-model="allServicesSelected"
                  type="checkbox"
                  id="all-services"
                  @change="toggleAllServices"
                  class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                >
                <label for="all-services" class="ml-2 text-sm font-medium text-gray-700 dark:text-gray-300">
                  Tous les services
                </label>
              </div>
              <hr class="my-2">
              <div v-for="service in services" :key="service.id" class="flex items-center">
                <input
                  v-model="form.service_ids"
                  :value="service.id"
                  type="checkbox"
                  :id="`service-${service.id}`"
                  class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                >
                <label :for="`service-${service.id}`" class="ml-2 text-sm text-gray-700 dark:text-gray-300">
                  {{ service.display_name || service.name }}
                </label>
              </div>
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              {{ $t('admin.promotions.applicableCountries') }}
            </label>
            <div class="grid grid-cols-2 md:grid-cols-3 gap-2">
              <div v-for="country in availableCountries" :key="country" class="flex items-center">
                <input
                  v-model="form.country_codes"
                  :value="country"
                  type="checkbox"
                  :id="`country-${country}`"
                  class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                >
                <label :for="`country-${country}`" class="ml-2 text-sm text-gray-700 dark:text-gray-300">
                  {{ getCountryName(country) }}
                </label>
              </div>
            </div>
          </div>

          <!-- Boutons -->
          <div class="flex justify-end space-x-3 pt-4">
            <button
              type="button"
              @click="$emit('close')"
              class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700"
            >
              {{ $t('admin.common.cancel') }}
            </button>
            <button
              type="submit"
              class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
            >
              {{ $t('admin.common.save') }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const props = defineProps({
  promotion: {
    type: Object,
    default: null
  },
  services: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['close', 'save'])

const form = ref({
  code: '',
  name: '',
  description: '',
  discount_type: 'percentage',
  discount_value: 0,
  min_purchase_points: 0,
  max_uses_total: null,
  max_uses_per_user: 1,
  valid_from: '',
  valid_until: '',
  service_ids: [],
  country_codes: ['FR', 'US', 'DE', 'ES', 'IT', 'GB', 'CA'],
  is_active: true
})

const availableCountries = ['FR', 'US', 'DE', 'ES', 'IT', 'GB', 'CA', 'JP', 'CN', 'AU', 'BR']

const countryNames = {
  'FR': 'France',
  'US': 'États-Unis',
  'DE': 'Allemagne',
  'ES': 'Espagne',
  'IT': 'Italie',
  'GB': 'Royaume-Uni',
  'CA': 'Canada',
  'JP': 'Japon',
  'CN': 'Chine',
  'AU': 'Australie',
  'BR': 'Brésil'
}

const allServicesSelected = computed({
  get() {
    return form.value.service_ids.length === props.services.length
  },
  set(value) {
    if (value) {
      form.value.service_ids = props.services.map(s => s.id)
    } else {
      form.value.service_ids = []
    }
  }
})

function toggleAllServices() {
  if (allServicesSelected.value) {
    form.value.service_ids = []
  } else {
    form.value.service_ids = props.services.map(s => s.id)
  }
}

function getCountryName(countryCode) {
  return countryNames[countryCode] || countryCode
}

function handleSubmit() {
  // Convertir les dates en format ISO
  const formData = {
    ...form.value,
    valid_from: new Date(form.value.valid_from).toISOString(),
    valid_until: new Date(form.value.valid_until).toISOString()
  }
  
  emit('save', formData)
}

onMounted(() => {
  if (props.promotion) {
    form.value = {
      ...props.promotion,
      valid_from: new Date(props.promotion.valid_from).toISOString().slice(0, 16),
      valid_until: new Date(props.promotion.valid_until).toISOString().slice(0, 16)
    }
  } else {
    // Valeurs par défaut pour une nouvelle promotion
    const now = new Date()
    const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000)
    const nextWeek = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000)
    
    form.value.valid_from = tomorrow.toISOString().slice(0, 16)
    form.value.valid_until = nextWeek.toISOString().slice(0, 16)
  }
})
</script>