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
import ServiceInputSection from '@/components/ServiceInputSection.vue'
import LLMService from '@/components/services/LLMService.vue'

const serviceStore = useServiceStore()

// Check if current service is an LLM
const isLLMService = computed(() => {
  return serviceStore.selectedCategory === 'llm' && 
    ['chatgpt', 'claude', 'gemini', 'chat'].includes(serviceStore.selectedService)
})

// Handle generation for non-LLM services
const handleGenerate = (data) => {
  // TODO: Implement generation for other services
  console.log('Generate request:', data)
}
</script>