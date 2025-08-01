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
        <div v-for="(message, index) in messages" :key="message.id" :class="[
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
import { ref, computed, onMounted, nextTick, watch } from 'vue'
import { useServiceStore } from '@/stores/service'
import { useAIServicesStore } from '@/stores/aiServices' 
import { useUserStore } from '@/stores/user'
import { useI18n } from 'vue-i18n'
import ServiceInputSection from '@/components/ServiceInputSection.vue'

const { t } = useI18n()
const serviceStore = useServiceStore()
const aiServicesStore = useAIServicesStore()
const userStore = useUserStore()

// État local
const messages = ref([])
const isGenerating = ref(false)
const error = ref(null)
const messagesContainer = ref(null)
const streamingMessageId = ref(null)

// Configuration OpenRouter
const OPENROUTER_API_URL = 'https://openrouter.ai/api/v1/chat/completions'
const OPENROUTER_API_KEY = import.meta.env.VITE_OPENROUTER_API_KEY

// Vérifier si la clé API est présente
if (!OPENROUTER_API_KEY) {
  console.error('OpenRouter API key is missing. Please add VITE_OPENROUTER_API_KEY to your .env file')
}

// Get selected service data
const selectedService = computed(() => {
  if (!serviceStore.selectedService) return null
  return aiServicesStore.services.find(s => s.id === serviceStore.selectedService)
})

// Utiliser l'api_endpoint du service sélectionné directement
const getOpenRouterModel = computed(() => {
  if (!selectedService.value) return 'openai/gpt-3.5-turbo'
  
  // Utiliser directement l'api_endpoint stocké dans la base de données
  return selectedService.value.api_endpoint || 'openai/gpt-3.5-turbo'
})

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

// Calcul du coût basé sur les données du service
const calculateCost = (text) => {
  if (!selectedService.value) return 1
  
  // Utiliser le coût défini dans la base de données
  const baseCost = selectedService.value.default_cost_points || 1
  
  // Pour les modèles LLM, on peut ajuster le coût en fonction de la longueur
  // mais on utilise le coût de base défini par l'admin
  const tokens = estimateTokens(text)
  const tokenFactor = Math.max(1, tokens / 1000) // Factor basé sur 1000 tokens
  
  return Math.max(1, Math.ceil(baseCost * tokenFactor))
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
    const estimatedCost = calculateCost(inputData.mainInput)
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
    
    // Préparer la requête
    // Vérifier si le modèle supporte le streaming (par défaut true)
    const supportsStreaming = selectedService.value?.supports_streaming !== false
    // Permettre aussi de désactiver via la config
    const enableStreaming = supportsStreaming && selectedService.value?.config?.enable_streaming !== false
    
    const requestBody = {
      model: getOpenRouterModel.value,
      messages: apiMessages,
      temperature: selectedService.value?.config?.temperature || 0.7,
      max_tokens: selectedService.value?.config?.max_tokens || 2048, // Réduire la limite par défaut
      stream: enableStreaming, // Streaming basé sur le support du modèle ET la config
      ...(selectedService.value?.config?.additional_params || {})
    }
    
    // Log de la requête envoyée
    console.log('🚀 === REQUÊTE ENVOYÉE AU LLM ===')
    console.log('URL:', OPENROUTER_API_URL)
    console.log('Modèle:', getOpenRouterModel.value)
    console.log('Service sélectionné:', selectedService.value?.name)
    console.log('API Endpoint du service:', selectedService.value?.api_endpoint)
    console.log('Support du streaming:', supportsStreaming ? '✅ Oui' : '❌ Non')
    console.log('Streaming activé:', enableStreaming ? '✅ Oui' : '❌ Non')
    console.log('Corps de la requête:', JSON.stringify(requestBody, null, 2))
    
    // Appel API OpenRouter
    const response = await fetch(OPENROUTER_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
        'HTTP-Referer': window.location.origin,
        'X-Title': 'nelo AI Platform'
      },
      body: JSON.stringify(requestBody)
    })
    
    // Log du statut de la réponse
    console.log('📡 === STATUT DE LA RÉPONSE ===')
    console.log('Statut HTTP:', response.status)
    console.log('Statut OK:', response.ok)
    console.log('Headers:', Object.fromEntries(response.headers.entries()))
    
    if (!response.ok) {
      // Essayer de récupérer le contenu brut de l'erreur
      const contentType = response.headers.get('content-type')
      console.log('❌ === ERREUR RÉPONSE LLM ===')
      console.log('Content-Type:', contentType)
      
      let errorMessage = t('llm.apiError')
      try {
        if (contentType && contentType.includes('application/json')) {
          const errorData = await response.json()
          console.log('Erreur JSON:', errorData)
          errorMessage = errorData.error?.message || errorData.message || errorMessage
        } else {
          // Si ce n'est pas du JSON, récupérer le texte brut
          const errorText = await response.text()
          console.log('Erreur texte brut:', errorText)
          errorMessage = `HTTP ${response.status}: ${errorText.substring(0, 200)}...`
        }
      } catch (parseError) {
        console.error('Impossible de parser l\'erreur:', parseError)
      }
      
      throw new Error(errorMessage)
    }
    
    // Vérifier le content-type de la réponse réussie
    const contentType = response.headers.get('content-type')
    const useStreaming = requestBody.stream && contentType && contentType.includes('text/event-stream')
    
    let assistantMessage = {
      id: Date.now() + 1,
      role: 'assistant',
      content: '',
      timestamp: new Date()
    }
    
    if (useStreaming) {
      // Gérer le streaming SSE
      console.log('🔄 === MODE STREAMING ACTIVÉ ===')
      messages.value.push(assistantMessage)
      streamingMessageId.value = assistantMessage.id
      
      const reader = response.body.getReader()
      const decoder = new TextDecoder()
      let buffer = ''
      let usage = null
      
      try {
        while (true) {
          const { done, value } = await reader.read()
          if (done) break
          
          buffer += decoder.decode(value, { stream: true })
          const lines = buffer.split('\n')
          buffer = lines.pop() || ''
          
          for (const line of lines) {
            if (line.startsWith('data: ')) {
              const jsonStr = line.slice(6)
              if (jsonStr === '[DONE]') {
                console.log('✅ === STREAMING TERMINÉ ===')
                break
              }
              
              try {
                const chunk = JSON.parse(jsonStr)
                console.log('📦 Chunk reçu:', chunk)
                
                if (chunk.choices && chunk.choices[0]?.delta?.content) {
                  const newContent = chunk.choices[0].delta.content
                  console.log('📝 Nouveau contenu:', newContent)
                  
                  // Mettre à jour le message en temps réel
                  const msgIndex = messages.value.findIndex(m => m.id === assistantMessage.id)
                  if (msgIndex !== -1) {
                    // Utiliser splice pour forcer la réactivité
                    const updatedMessage = {
                      ...messages.value[msgIndex],
                      content: messages.value[msgIndex].content + newContent
                    }
                    messages.value.splice(msgIndex, 1, updatedMessage)
                    
                    console.log('📄 Contenu total actuel:', updatedMessage.content.length, 'caractères')
                  }
                  // Scroll vers le bas après chaque update
                  await nextTick()
                  await scrollToBottom()
                }
                
                // Capturer les données d'utilisation si disponibles
                if (chunk.usage) {
                  usage = chunk.usage
                }
              } catch (e) {
                console.warn('Impossible de parser le chunk:', jsonStr, e)
              }
            }
          }
        }
      } finally {
        reader.releaseLock()
        streamingMessageId.value = null
      }
      
      console.log('✅ === RÉPONSE STREAMING COMPLÈTE ===')
      console.log('Contenu final:', assistantMessage.content)
      
      // Calculer le coût avec les données d'utilisation si disponibles
      console.log('💰 === CALCUL DU COÛT (STREAMING) ===')
      if (usage) {
        const actualTokens = usage.prompt_tokens + usage.completion_tokens
        const tokenFactor = Math.max(1, actualTokens / 1000)
        const actualCost = Math.max(1, Math.ceil(selectedService.value.default_cost_points * tokenFactor))
        console.log('Tokens utilisés:', usage)
        console.log('Coût calculé:', actualCost)
        await userStore.deductPoints(actualCost)
      } else {
        console.log('Pas de données d\'utilisation, utilisation du coût estimé:', estimatedCost)
        await userStore.deductPoints(estimatedCost)
      }
      
    } else {
      // Mode non-streaming (JSON classique)
      if (!contentType || !contentType.includes('application/json')) {
        console.error('⚠️ Content-Type inattendu:', contentType)
        const rawText = await response.text()
        console.error('Contenu brut reçu:', rawText.substring(0, 500))
        throw new Error('La réponse n\'est pas du JSON valide')
      }
      
      const data = await response.json()
      
      console.log('✅ === RÉPONSE REÇUE DU LLM ===')
      console.log('Réponse complète:', JSON.stringify(data, null, 2))
      
      assistantMessage.content = data.choices[0].message.content
      messages.value.push(assistantMessage)
      
      // Déduire les points basés sur l'utilisation réelle ou le coût estimé
      console.log('💰 === CALCUL DU COÛT ===')
      if (data.usage) {
        const actualTokens = data.usage.prompt_tokens + data.usage.completion_tokens
        const tokenFactor = Math.max(1, actualTokens / 1000)
        const actualCost = Math.max(1, Math.ceil(selectedService.value.default_cost_points * tokenFactor))
        console.log('Tokens utilisés:', data.usage)
        console.log('Coût calculé:', actualCost)
        await userStore.deductPoints(actualCost)
      } else {
        console.log('Pas de données d\'utilisation, utilisation du coût estimé:', estimatedCost)
        await userStore.deductPoints(estimatedCost)
      }
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

onMounted(async () => {
  messagesContainer.value = document.querySelector('.overflow-y-auto')
  
  // S'assurer que les services sont chargés
  if (aiServicesStore.services.length === 0) {
    await aiServicesStore.fetchAllData()
  }
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