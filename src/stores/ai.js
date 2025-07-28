import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { openRouterService } from '@/services/openrouter'
import { falService } from '@/services/fal'

export const useAiStore = defineStore('ai', () => {
  // État
  const isLoading = ref(false)
  const error = ref(null)
  const currentConversation = ref([])
  const selectedLlmModel = ref('meta-llama/llama-3.1-8b-instruct:free')
  const selectedImageModel = ref('fal-ai/flux/schnell')
  
  // Modèles disponibles
  const llmModels = computed(() => openRouterService.getAvailableModels())
  const imageModels = computed(() => falService.getAvailableModels().imageGeneration)
  const videoModels = computed(() => falService.getAvailableModels().videoGeneration)
  const audioModels = computed(() => falService.getAvailableModels().audioProcessing)

  // Actions pour OpenRouter (LLMs)
  async function generateText(messages, options = {}) {
    isLoading.value = true
    error.value = null
    
    try {
      const response = await openRouterService.generateCompletion({
        model: selectedLlmModel.value,
        messages,
        ...options
      })
      
      const assistantMessage = response.choices[0].message
      currentConversation.value.push(...messages, assistantMessage)
      
      return response
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      isLoading.value = false
    }
  }

  async function streamText(messages, onChunk, options = {}) {
    isLoading.value = true
    error.value = null
    
    try {
      await openRouterService.streamCompletion({
        model: selectedLlmModel.value,
        messages,
        onChunk,
        ...options
      })
      
      currentConversation.value.push(...messages)
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      isLoading.value = false
    }
  }

  // Actions pour Fal AI
  async function generateImage(prompt, options = {}) {
    isLoading.value = true
    error.value = null
    
    try {
      const response = await falService.generateImage({
        model: selectedImageModel.value,
        prompt,
        ...options
      })
      
      return response
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      isLoading.value = false
    }
  }

  async function generateVideo(imageUrl, prompt, options = {}) {
    isLoading.value = true
    error.value = null
    
    try {
      const response = await falService.generateVideo({
        imageUrl,
        prompt,
        ...options
      })
      
      return response
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      isLoading.value = false
    }
  }

  async function upscaleImage(imageUrl, options = {}) {
    isLoading.value = true
    error.value = null
    
    try {
      const response = await falService.upscaleImage({
        imageUrl,
        ...options
      })
      
      return response
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      isLoading.value = false
    }
  }

  async function removeBackground(imageUrl, options = {}) {
    isLoading.value = true
    error.value = null
    
    try {
      const response = await falService.removeBackground({
        imageUrl,
        ...options
      })
      
      return response
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      isLoading.value = false
    }
  }

  async function transcribeAudio(audioUrl, options = {}) {
    isLoading.value = true
    error.value = null
    
    try {
      const response = await falService.transcribeAudio({
        audioUrl,
        ...options
      })
      
      return response
    } catch (err) {
      error.value = err.message
      throw err
    } finally {
      isLoading.value = false
    }
  }

  // Utilitaires
  function clearConversation() {
    currentConversation.value = []
  }

  function clearError() {
    error.value = null
  }

  function setLlmModel(modelId) {
    selectedLlmModel.value = modelId
  }

  function setImageModel(modelId) {
    selectedImageModel.value = modelId
  }

  return {
    // État
    isLoading,
    error,
    currentConversation,
    selectedLlmModel,
    selectedImageModel,
    
    // Computed
    llmModels,
    imageModels,
    videoModels,
    audioModels,
    
    // Actions
    generateText,
    streamText,
    generateImage,
    generateVideo,
    upscaleImage,
    removeBackground,
    transcribeAudio,
    clearConversation,
    clearError,
    setLlmModel,
    setImageModel
  }
})