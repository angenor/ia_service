<template>
  <div class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
    <div class="relative top-20 mx-auto p-5 border w-2xl max-w-2xl shadow-lg rounded-md bg-white dark:bg-gray-800">
      <div class="mt-3">
        <!-- En-tête -->
        <div class="flex items-center justify-between mb-4">
          <h3 class="text-lg font-medium text-gray-900 dark:text-white">
            {{ $t('admin.services.manageAbilities') }} - {{ service?.name }}
          </h3>
          <button @click="$emit('close')" class="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300">
            <font-awesome-icon icon="times" />
          </button>
        </div>

        <!-- Liste des capacités disponibles -->
        <div class="space-y-4">
          <div v-for="category in categorizedAbilities" :key="category.id" class="border-b border-gray-200 dark:border-gray-700 pb-4">
            <h4 class="font-medium text-gray-900 dark:text-white mb-3">{{ category.name }}</h4>
            
            <div class="space-y-2">
              <div v-for="ability in category.abilities" :key="ability.id" class="flex items-center justify-between p-3 border border-gray-200 dark:border-gray-600 rounded-md hover:bg-gray-50 dark:hover:bg-gray-700">
                <div class="flex items-center space-x-3">
                  <input
                    type="checkbox"
                    :id="`ability-${ability.id}`"
                    v-model="selectedAbilities[ability.id]"
                    class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                  >
                  <label :for="`ability-${ability.id}`" class="cursor-pointer">
                    <div class="font-medium text-gray-900 dark:text-white">{{ ability.name }}</div>
                    <div v-if="ability.from_type && ability.to_type" class="text-sm text-gray-500 dark:text-gray-400">
                      {{ ability.from_type }} → {{ ability.to_type }}
                    </div>
                  </label>
                </div>
                
                <!-- Multiplicateur de coût -->
                <div v-if="selectedAbilities[ability.id]" class="flex items-center space-x-2">
                  <label class="text-sm text-gray-600 dark:text-gray-400">Multiplicateur:</label>
                  <input
                    v-model.number="costMultipliers[ability.id]"
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
  service: {
    type: Object,
    required: true
  },
  abilities: {
    type: Array,
    required: true
  },
  serviceAbilities: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['close', 'save'])

const selectedAbilities = ref({})
const costMultipliers = ref({})

// Grouper les capacités par catégorie
const categorizedAbilities = computed(() => {
  const grouped = {}
  
  props.abilities.forEach(ability => {
    const categoryName = ability.service_categories?.name || 'Sans catégorie'
    const categoryId = ability.category_id || 'no-category'
    
    if (!grouped[categoryId]) {
      grouped[categoryId] = {
        id: categoryId,
        name: categoryName,
        abilities: []
      }
    }
    
    grouped[categoryId].abilities.push(ability)
  })
  
  return Object.values(grouped)
})

function handleSave() {
  const updates = []
  
  // Créer la liste des capacités à mettre à jour
  Object.keys(selectedAbilities.value).forEach(abilityId => {
    if (selectedAbilities.value[abilityId]) {
      updates.push({
        ability_id: abilityId,
        cost_multiplier: costMultipliers.value[abilityId] || 1.0,
        is_active: true
      })
    }
  })
  
  emit('save', props.service.id, updates)
}

onMounted(() => {
  // Initialiser avec les capacités existantes du service
  props.serviceAbilities.forEach(sa => {
    selectedAbilities.value[sa.id] = true
    costMultipliers.value[sa.id] = sa.cost_multiplier || 1.0
  })
})
</script>