<template>
  <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
    <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white dark:bg-gray-800">
      <div class="mt-3">
        <!-- En-tête -->
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-medium text-gray-900 dark:text-white">
            {{ pricing ? 'Modifier la tarification' : 'Ajouter une tarification' }}
          </h3>
          <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300">
            <font-awesome-icon icon="times" />
          </button>
        </div>

        <!-- Formulaire -->
        <form @submit.prevent="handleSubmit" class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Service
            </label>
            <select
              v-model="form.service_id"
              required
              :disabled="!!pricing"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white disabled:opacity-50"
            >
              <option value="">Sélectionner un service</option>
              <option v-for="service in services" :key="service.id" :value="service.id">
                {{ service.display_name || service.name }}
              </option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Pays
            </label>
            <select
              v-model="form.country_code"
              required
              :disabled="!!pricing"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white disabled:opacity-50"
            >
              <option value="">Sélectionner un pays</option>
              <option v-for="country in countries" :key="country.code" :value="country.code">
                {{ country.flag }} {{ country.name }}
              </option>
            </select>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Prix en points
            </label>
            <input
              v-model.number="form.cost_points"
              type="number"
              min="1"
              required
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            >
          </div>

          <div v-if="form.cost_points" class="p-3 bg-gray-50 dark:bg-gray-700 rounded-md">
            <div class="text-sm text-gray-600 dark:text-gray-300">
              <div>Prix configuré: {{ form.cost_points }} points</div>
              <div>Équivalent: ${{ (form.cost_points * 0.01).toFixed(2) }}</div>
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
  pricing: {
    type: Object,
    default: null
  },
  services: {
    type: Array,
    default: () => []
  },
  countries: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['close', 'save'])

const form = ref({
  service_id: '',
  country_code: '',
  cost_points: 0
})


function handleSubmit() {
  emit('save', form.value)
}

onMounted(() => {
  if (props.pricing) {
    form.value = {
      service_id: props.pricing.service_id,
      country_code: props.pricing.country_code,
      cost_points: props.pricing.cost_points || props.pricing.base_price_points || 0
    }
  }
})
</script>