<template>
  <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
    <div class="relative top-10 mx-auto p-5 border w-full max-w-2xl shadow-lg rounded-md bg-white dark:bg-gray-800">
      <div class="mt-3">
        <!-- En-tête -->
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-medium text-gray-900 dark:text-white">
            {{ service ? $t('admin.services.editService') : $t('admin.services.addService') }}
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
                {{ $t('admin.services.serviceName') }}
              </label>
              <input
                v-model="form.name"
                type="text"
                required
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('admin.services.serviceDisplayName') }}
              </label>
              <input
                v-model="form.display_name"
                type="text"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              {{ $t('admin.services.serviceDescription') }}
            </label>
            <textarea
              v-model="form.description"
              rows="3"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            ></textarea>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Sous-catégorie
              </label>
              <select
                v-model="form.subcategory_id"
                required
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
                <option value="">Sélectionner une sous-catégorie</option>
                <option v-for="subcategory in subcategories" :key="subcategory.id" :value="subcategory.id">
                  {{ subcategory.name }}
                </option>
              </select>
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('admin.services.serviceProvider') }}
              </label>
              <select
                v-model="form.provider"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
                <option value="openrouter">OpenRouter</option>
                <option value="fal">Fal.ai</option>
                <option value="openai">OpenAI</option>
                <option value="anthropic">Anthropic</option>
                <option value="elevenlabs">ElevenLabs</option>
              </select>
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('admin.services.serviceEndpoint') }}
              </label>
              <input
                v-model="form.api_endpoint"
                type="url"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                {{ $t('admin.services.serviceModel') }}
              </label>
              <input
                v-model="form.model_name"
                type="text"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              {{ $t('admin.services.serviceFeatures') }}
            </label>
            <textarea
              v-model="form.features"
              rows="2"
              placeholder="Fonctionnalités séparées par des virgules"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            ></textarea>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              {{ $t('admin.services.serviceLimitations') }}
            </label>
            <textarea
              v-model="form.limitations"
              rows="2"
              placeholder="Limitations séparées par des virgules"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            ></textarea>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div class="flex items-center">
              <input
                v-model="form.is_active"
                type="checkbox"
                id="is-active"
                class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              >
              <label for="is-active" class="ml-2 text-sm font-medium text-gray-700 dark:text-gray-300">
                {{ $t('admin.services.isActive') }}
              </label>
            </div>

            <div class="flex items-center">
              <input
                v-model="form.is_new"
                type="checkbox"
                id="is-new"
                class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              >
              <label for="is-new" class="ml-2 text-sm font-medium text-gray-700 dark:text-gray-300">
                {{ $t('admin.services.isNew') }}
              </label>
            </div>

            <div v-if="form.is_new">
              <label class="block text-xs font-medium text-gray-700 dark:text-gray-300 mb-1">
                {{ $t('admin.services.newBadgeUntil') }}
              </label>
              <input
                v-model="form.new_badge_until"
                type="date"
                class="w-full px-2 py-1 text-sm border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
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
import { ref, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const props = defineProps({
  service: {
    type: Object,
    default: null
  },
  subcategories: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['close', 'save'])

const form = ref({
  name: '',
  display_name: '',
  description: '',
  subcategory_id: '',
  provider: 'openrouter',
  api_endpoint: '',
  model_name: '',
  features: '',
  limitations: '',
  is_active: true,
  is_new: false,
  new_badge_until: null
})

function handleSubmit() {
  // Convertir les chaînes de caractères en tableaux pour features et limitations
  const formData = {
    ...form.value,
    features: form.value.features ? form.value.features.split(',').map(f => f.trim()) : [],
    limitations: form.value.limitations ? form.value.limitations.split(',').map(l => l.trim()) : []
  }
  
  emit('save', formData)
}

onMounted(() => {
  if (props.service) {
    form.value = {
      ...props.service,
      features: Array.isArray(props.service.features) ? props.service.features.join(', ') : props.service.features || '',
      limitations: Array.isArray(props.service.limitations) ? props.service.limitations.join(', ') : props.service.limitations || '',
      new_badge_until: props.service.new_badge_until ? new Date(props.service.new_badge_until).toISOString().split('T')[0] : null
    }
  }
})
</script>