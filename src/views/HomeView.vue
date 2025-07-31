<template>
  <div class="space-y-6">
    <!-- LLM Service Component -->
    <LLMService v-if="isLLMService" />
    
    <!-- Input Section Component for other services -->
    <ServiceInputSection v-else @generate="handleGenerate" />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useServiceStore } from '@/stores/service'
import { useAIServicesStore } from '@/stores/aiServices'
import ServiceInputSection from '@/components/ServiceInputSection.vue'
import LLMService from '@/components/services/LLMService.vue'

const serviceStore = useServiceStore()
const aiServicesStore = useAIServicesStore()

// Get the selected service data
const selectedService = computed(() => {
  if (!serviceStore.selectedService) return null
  return aiServicesStore.services.find(s => s.id === serviceStore.selectedService)
})

// Check if current service is an LLM
const isLLMService = computed(() => {
  if (!selectedService.value) return false
  
  // Vérifier si le service appartient à la catégorie LLM
  const serviceCategory = aiServicesStore.categories.find(c => c.id === selectedService.value.category_id)
  return serviceCategory?.slug === 'llm'
})

// Handle generation for non-LLM services
const handleGenerate = (data) => {
  // TODO: Implement generation for other services
  console.log('Generate request:', data)
}
</script>