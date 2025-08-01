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
                Slug (identifiant unique)
              </label>
              <input
                v-model="form.slug"
                type="text"
                required
                pattern="[a-z0-9-]+"
                placeholder="ex: claude-opus-4"
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
                {{ $t('admin.services.category') }}
              </label>
              <select
                v-model="form.category_id"
                required
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
                <option value="">Sélectionner une catégorie</option>
                <option v-for="category in categories" :key="category.id" :value="category.id">
                  {{ category.name }}
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
                <option value="google">Google</option>
                <option value="xai">xAI</option>
                <option value="meta-llama">Meta Llama</option>
                <option value="deepseek">DeepSeek</option>
                <option value="qwen">Qwen</option>
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
                type="text"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Icône (nom Font Awesome)
              </label>
              <input
                v-model="form.icon"
                type="text"
                placeholder="ex: brain, code, image"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                URL de l'image PNG
              </label>
              <input
                v-model="form.png"
                type="url"
                placeholder="https://example.com/service-icon.png"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                URL de la vidéo de démonstration
              </label>
              <input
                v-model="form.video"
                type="url"
                placeholder="https://example.com/demo.mp4"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Coût en points (minimum)
              </label>
              <input
                v-model.number="form.default_cost_points"
                type="number"
                min="0"
                required
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
              >
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Coût API en USD
              </label>
              <input
                v-model.number="form.api_cost_usd"
                type="number"
                step="0.000001"
                min="0"
                placeholder="0.000000"
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
              placeholder='["Feature 1", "Feature 2", "Feature 3"]'
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
              placeholder='{"rate_limit": "100 req/min", "max_output": "4096 tokens"}'
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
            ></textarea>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Configuration (JSON)
            </label>
            <textarea
              v-model="form.config"
              rows="3"
              placeholder='{"temperature": 0.7, "max_tokens": 2048}'
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white font-mono text-sm"
            ></textarea>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
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
                v-model="form.supports_streaming"
                type="checkbox"
                id="supports-streaming"
                class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
              >
              <label for="supports-streaming" class="ml-2 text-sm font-medium text-gray-700 dark:text-gray-300">
                Supporte le streaming SSE
              </label>
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
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

const props = defineProps({
  service: {
    type: Object,
    default: null
  },
  categories: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['close', 'save'])

const form = ref({
  name: '',
  slug: '',
  description: '',
  category_id: '',
  provider: 'openrouter',
  api_endpoint: '',
  icon: '',
  png: '',
  video: '',
  default_cost_points: 1,
  api_cost_usd: 0,
  features: '',
  limitations: '',
  config: '',
  is_active: true,
  is_new: false,
  new_badge_until: null,
  supports_streaming: true
})

function handleSubmit() {
  try {
    // Parser les champs JSON
    const formData = {
      ...form.value,
      features: form.value.features ? JSON.parse(form.value.features) : [],
      limitations: form.value.limitations ? JSON.parse(form.value.limitations || '{}') : {},
      config: form.value.config ? JSON.parse(form.value.config || '{}') : {},
      api_cost_usd: parseFloat(form.value.api_cost_usd) || 0,
      default_cost_points: parseInt(form.value.default_cost_points) || 1
    }
    
    // Valider le slug
    if (!formData.slug.match(/^[a-z0-9-]+$/)) {
      alert('Le slug doit contenir uniquement des lettres minuscules, chiffres et tirets')
      return
    }
    
    emit('save', formData)
  } catch (error) {
    alert('Erreur dans le format JSON: ' + error.message)
  }
}

onMounted(() => {
  if (props.service) {
    form.value = {
      name: props.service.name || '',
      slug: props.service.slug || '',
      description: props.service.description || '',
      category_id: props.service.category_id || '',
      provider: props.service.provider || 'openrouter',
      api_endpoint: props.service.api_endpoint || '',
      icon: props.service.icon || '',
      png: props.service.png || '',
      video: props.service.video || '',
      default_cost_points: props.service.default_cost_points || 1,
      api_cost_usd: props.service.api_cost_usd || 0,
      features: Array.isArray(props.service.features) ? JSON.stringify(props.service.features, null, 2) : props.service.features || '[]',
      limitations: typeof props.service.limitations === 'object' ? JSON.stringify(props.service.limitations, null, 2) : props.service.limitations || '{}',
      config: typeof props.service.config === 'object' ? JSON.stringify(props.service.config, null, 2) : props.service.config || '{}',
      is_active: props.service.is_active !== false,
      is_new: props.service.is_new || false,
      new_badge_until: props.service.new_badge_until ? new Date(props.service.new_badge_until).toISOString().split('T')[0] : null,
      supports_streaming: props.service.supports_streaming !== false
    }
  }
})
</script>