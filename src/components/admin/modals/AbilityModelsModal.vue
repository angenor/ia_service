<template>
  <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
    <div class="relative top-20 mx-auto p-5 border w-2xl max-w-2xl shadow-lg rounded-md bg-white dark:bg-gray-800">
      <div class="mt-3">
        <!-- En-tête -->
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-medium text-gray-900 dark:text-white">
            {{ $t('admin.services.manageModels') }} - {{ ability?.name }}
          </h3>
          <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300">
            <font-awesome-icon icon="times" />
          </button>
        </div>

        <!-- Description de la capacité -->
        <div class="mb-6 p-4 bg-gray-50 dark:bg-gray-700 rounded-md">
          <p class="text-sm text-gray-600 dark:text-gray-300">{{ ability?.description }}</p>
          <div v-if="ability?.from_type && ability?.to_type" class="mt-2 text-sm font-medium text-gray-700 dark:text-gray-200">
            Transformation: {{ ability.from_type }} → {{ ability.to_type }}
          </div>
        </div>

        <!-- Liste des modèles disponibles -->
        <div class="space-y-4">
          <h4 class="font-medium text-gray-900 dark:text-white">Modèles disponibles</h4>
          
          <div class="space-y-2 max-h-96 overflow-y-auto">
            <div v-for="service in filteredServices" :key="service.id" 
                 class="flex items-center justify-between p-3 border border-gray-200 dark:border-gray-600 rounded-md hover:bg-gray-50 dark:hover:bg-gray-700">
              <div class="flex items-center space-x-3">
                <input
                  type="checkbox"
                  :id="`service-${service.id}`"
                  v-model="selectedServices[service.id]"
                  class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                >
                <label :for="`service-${service.id}`" class="cursor-pointer">
                  <div class="font-medium text-gray-900 dark:text-white">{{ service.name }}</div>
                  <div class="text-sm text-gray-500 dark:text-gray-400">
                    {{ service.provider }} - {{ service.service_categories?.name }}
                  </div>
                </label>
              </div>
              
              <!-- Multiplicateur de coût -->
              <div v-if="selectedServices[service.id]" class="flex items-center space-x-2">
                <label class="text-sm text-gray-600 dark:text-gray-400">Multiplicateur:</label>
                <input
                  v-model.number="costMultipliers[service.id]"
                  type="number"
                  min="0.1"
                  max="10"
                  step="0.1"
                  class="w-20 px-2 py-1 border border-gray-300 dark:border-gray-600 rounded bg-white dark:bg-gray-700 text-gray-900 dark:text-white"
                >
              </div>
            </div>
          </div>
        </div>

        <!-- Résumé -->
        <div class="mt-4 text-sm text-gray-600 dark:text-gray-400">
          {{ Object.keys(selectedServices).filter(id => selectedServices[id]).length }} modèle(s) sélectionné(s)
        </div>

        <!-- Boutons -->
        <div class="flex justify-end space-x-3 pt-6 border-t border-gray-200 dark:border-gray-700 mt-6">
          <button
            type="button"
            @click="$emit('close')"
            class="px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-md text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700"
          >
            {{ $t('admin.common.cancel') }}
          </button>
          <button
            @click="handleSave"
            class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
          >
            {{ $t('admin.common.save') }}
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
  ability: {
    type: Object,
    required: true
  },
  services: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['close', 'save'])

const selectedServices = ref({})
const costMultipliers = ref({})

// Filtrer seulement les services de la même catégorie que la capacité
const filteredServices = computed(() => {
  return props.services.filter(service => 
    service.category_id === props.ability.category_id && service.is_active
  )
})

function handleSave() {
  const updates = []
  
  // Créer la liste des services à associer à cette capacité
  Object.keys(selectedServices.value).forEach(serviceId => {
    if (selectedServices.value[serviceId]) {
      updates.push({
        service_id: serviceId,
        cost_multiplier: costMultipliers.value[serviceId] || 1.0,
        is_active: true
      })
    }
  })
  
  emit('save', props.ability.id, updates)
}

onMounted(() => {
  // TODO: Initialiser avec les services qui ont déjà cette capacité
  // Cela nécessiterait d'avoir les données service_model_abilities
})
</script>