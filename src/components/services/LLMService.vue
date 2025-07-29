<template>
  <div class="max-w-4xl mx-auto space-y-4">
    <!-- Messages Container -->
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-4 min-h-[400px] max-h-[600px] overflow-y-auto">
      <div v-if="messages.length === 0" class="flex items-center justify-center h-full min-h-[350px]">
        <div class="text-center">
          <font-awesome-icon icon="comments" class="text-4xl text-gray-400 dark:text-gray-600 mb-4" />
          <p class="text-gray-600 dark:text-gray-400">{{ $t('llm.startConversation') }}</p>
        </div>
      </div>
      
      <div v-else class="space-y-4">
        <div v-for="message in messages" :key="message.id" :class="[
          'flex',
          message.role === 'user' ? 'justify-end' : 'justify-start'
        ]">
          <div :class="[
            'max-w-[70%] rounded-lg p-3',
            message.role === 'user' 
              ? 'bg-blue-500 text-white' 
              : 'bg-gray-100 dark:bg-gray-700 text-gray-900 dark:text-white'
          ]">
            <p class="text-sm whitespace-pre-wrap">{{ message.content }}</p>
            <p class="text-xs mt-1 opacity-70">
              {{ formatTime(message.timestamp) }}
            </p>
          </div>
        </div>
        
        <!-- Loading indicator -->
        <div v-if="isGenerating" class="flex justify-start">
          <div class="bg-gray-100 dark:bg-gray-700 rounded-lg p-3">
            <div class="flex space-x-2">
              <div class="w-2 h-2 bg-gray-500 rounded-full animate-bounce" style="animation-delay: 0ms"></div>
              <div class="w-2 h-2 bg-gray-500 rounded-full animate-bounce" style="animation-delay: 150ms"></div>
              <div class="w-2 h-2 bg-gray-500 rounded-full animate-bounce" style="animation-delay: 300ms"></div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Input Section -->
    <ServiceInputSection 
      @generate="handleGenerate"
      :isGenerating="isGenerating"
    />

    <!-- Error Message -->
    <div v-if="error" class="bg-red-100 dark:bg-red-900/20 border border-red-400 dark:border-red-600 rounded-lg p-3">
      <p class="text-sm text-red-700 dark:text-red-300">{{ error }}</p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, nextTick, watch } from 'vue'
import { useServiceStore } from '@/stores/service'
import { useUserStore } from '@/stores/user'
import { useI18n } from 'vue-i18n'
import ServiceInputSection from '@/components/ServiceInputSection.vue'

const { t } = useI18n()
const serviceStore = useServiceStore()
const userStore = useUserStore()

// État local
const messages = ref([])
const isGenerating = ref(false)
const error = ref(null)
const messagesContainer = ref(null)

// Configuration OpenRouter
const OPENROUTER_API_URL = 'https://openrouter.ai/api/v1/chat/completions'
const OPENROUTER_API_KEY = import.meta.env.VITE_OPENROUTER_API_KEY

// Vérifier si la clé API est présente
if (!OPENROUTER_API_KEY) {
  console.error('OpenRouter API key is missing. Please add VITE_OPENROUTER_API_KEY to your .env file')
}

// Map des modèles vers les identifiants OpenRouter
const modelMapping = {
  // ChatGPT
  'gpt-3.5-turbo': 'openai/gpt-3.5-turbo',
  'gpt-4': 'openai/gpt-4',
  'gpt-4-turbo': 'openai/gpt-4-turbo-preview',
  
  // Claude
  'claude-3-haiku': 'anthropic/claude-3-haiku',
  'claude-3-sonnet': 'anthropic/claude-3-sonnet',
  'claude-3-opus': 'anthropic/claude-3-opus',
  
  // Gemini
  'gemini-pro': 'google/gemini-pro',
  'gemini-pro-vision': 'google/gemini-pro-vision',
  
  // Autres modèles pour le chat générique
  'llama-3': 'meta-llama/llama-3-70b-instruct'
}

// Tarifs OpenRouter par million de tokens (en USD) - basés sur la documentation officielle
const openRouterPricing = {
  'gpt-3.5-turbo': { input: 0.50, output: 1.50 },
  'gpt-4': { input: 30.00, output: 60.00 },
  'gpt-4-turbo': { input: 10.00, output: 30.00 },
  'claude-3-haiku': { input: 0.25, output: 1.25 },
  'claude-3-sonnet': { input: 3.00, output: 15.00 },
  'claude-3-opus': { input: 15.00, output: 75.00 },
  'gemini-pro': { input: 2.50, output: 7.50 },
  'gemini-pro-vision': { input: 2.50, output: 7.50 },
  'llama-3': { input: 0.70, output: 0.80 }
}

// Formatage du temps
const formatTime = (timestamp) => {
  const date = new Date(timestamp)
  return date.toLocaleTimeString('fr-FR', { 
    hour: '2-digit', 
    minute: '2-digit' 
  })
}

// Scroll vers le bas
const scrollToBottom = async () => {
  await nextTick()
  if (messagesContainer.value) {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
  }
}

// Estimation du nombre de tokens (approximation)
const estimateTokens = (text) => {
  // Approximation: 1 token ≈ 4 caractères
  return Math.ceil(text.length / 4)
}

// Calcul du coût estimé basé sur les tarifs OpenRouter
const calculateCost = (text, model) => {
  const pricing = openRouterPricing[model]
  if (!pricing) return 1
  
  const tokens = estimateTokens(text)
  // Estimation: 80% des tokens en output pour une conversation
  const inputTokens = tokens
  const outputTokens = Math.ceil(tokens * 0.8)
  
  const costUSD = (inputTokens * pricing.input / 1000000) + 
                  (outputTokens * pricing.output / 1000000)
  
  // Convertir en points (100 points = 1 USD) et assurer un minimum de 1 point
  return Math.max(1, Math.ceil(costUSD * 100))
}

// Gestion de la génération
const handleGenerate = async (inputData) => {
  if (!inputData.mainInput || inputData.mainInput.trim() === '') return
  
  const userMessage = {
    id: Date.now(),
    role: 'user',
    content: inputData.mainInput.trim(),
    timestamp: new Date()
  }
  
  messages.value.push(userMessage)
  isGenerating.value = true
  error.value = null
  
  await scrollToBottom()
  
  try {
    // Vérifier les points de l'utilisateur
    const estimatedCost = calculateCost(inputData.mainInput, serviceStore.generationOptions.model)
    if (userStore.points < estimatedCost) {
      throw new Error(t('llm.insufficientPoints'))
    }
    
    // Préparer les messages pour l'API
    const apiMessages = messages.value.map(msg => ({
      role: msg.role,
      content: msg.content
    }))
    
    // Vérifier la clé API avant l'appel
    if (!OPENROUTER_API_KEY) {
      throw new Error('OpenRouter API key is not configured. Please check your .env file.')
    }
    
    // Appel API OpenRouter
    const response = await fetch(OPENROUTER_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
        'HTTP-Referer': window.location.origin,
        'X-Title': 'ePavillon AI Platform'
      },
      body: JSON.stringify({
        model: modelMapping[serviceStore.generationOptions.model] || 'openai/gpt-3.5-turbo',
        messages: apiMessages,
        temperature: serviceStore.generationOptions.temperature || 0.7,
        max_tokens: 1000,
        stream: false
      })
    })
    
    if (!response.ok) {
      const errorData = await response.json()
      throw new Error(errorData.error?.message || t('llm.apiError'))
    }
    
    const data = await response.json()
    
    // Ajouter la réponse de l'assistant
    const assistantMessage = {
      id: Date.now() + 1,
      role: 'assistant',
      content: data.choices[0].message.content,
      timestamp: new Date()
    }
    
    messages.value.push(assistantMessage)
    
    // Déduire les points basés sur l'utilisation réelle
    const pricing = openRouterPricing[serviceStore.generationOptions.model]
    if (pricing && data.usage) {
      const costUSD = (data.usage.prompt_tokens * pricing.input / 1000000) + 
                      (data.usage.completion_tokens * pricing.output / 1000000)
      const actualCost = Math.max(1, Math.ceil(costUSD * 100))
      await userStore.deductPoints(actualCost)
    }
    
  } catch (err) {
    console.error('LLM Error:', err)
    error.value = err.message || t('llm.genericError')
  } finally {
    isGenerating.value = false
    await scrollToBottom()
  }
}

// Réinitialiser la conversation quand on change de service
watch(() => serviceStore.selectedService, () => {
  messages.value = []
  error.value = null
})

onMounted(() => {
  messagesContainer.value = document.querySelector('.overflow-y-auto')
})
</script>

<style scoped>
@keyframes bounce {
  0%, 80%, 100% {
    transform: translateY(0);
  }
  40% {
    transform: translateY(-10px);
  }
}
</style>