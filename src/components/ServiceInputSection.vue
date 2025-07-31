<template>
  <div class="max-w-4xl mx-auto shadow-2xl rounded-2xl">
    <!-- Service Selection Info -->
    <div v-if="!serviceStore.isServiceSelected" class="text-center py-16">
      <font-awesome-icon icon="wand-magic-sparkles" class="text-4xl text-gray-400 dark:text-gray-600 mb-4" />
      <p class="text-gray-600 dark:text-gray-400">{{ $t('input.selectServicePrompt') }}</p>
    </div>

    <!-- Main Input Container when service is selected -->
    <div v-else class="bg-white dark:bg-gray-900 rounded-2xl border border-gray-200 dark:border-gray-700 overflow-hidden">
      <!-- Input Section -->
      <div class="flex items-start p-4 space-x-4">
        <!-- Add Button -->
        <button 
          v-if="config?.allowFileUpload"
          @click="$refs.fileInput?.click()"
          class="flex-shrink-0 w-10 h-10 border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-full flex items-center justify-center hover:border-gray-400 dark:hover:border-gray-500 transition-colors mt-1"
        >
          <font-awesome-icon icon="plus" class="text-gray-400 dark:text-gray-500" />
        </button>

        <!-- Main Input Area -->
        <div class="flex-1 min-w-0">
          <!-- Textarea Input -->
          <textarea 
            v-if="config?.mainInput?.type === 'textarea'"
            v-model="mainInputValue"
            :placeholder="dynamicPlaceholder"
            :rows="1"
            @input="autoResize"
            @focus="pauseTypewriter"
            @blur="resumeTypewriter"
            ref="textareaRef"
            class="w-full p-0 border-0 resize-none text-lg bg-transparent text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-0 leading-relaxed min-h-[2rem]"
          ></textarea>

          <!-- File Display -->
          <div v-else-if="config?.mainInput?.type === 'file' && uploadedFile" class="py-2">
            <div class="flex items-center space-x-3">
              <div class="flex-shrink-0">
                <img 
                  v-if="isImage(uploadedFile)" 
                  :src="filePreview" 
                  alt="Upload preview"
                  class="w-16 h-16 object-cover rounded-lg border border-gray-200 dark:border-gray-700"
                />
                <div v-else class="w-16 h-16 bg-gray-100 dark:bg-gray-800 rounded-lg flex items-center justify-center border border-gray-200 dark:border-gray-700">
                  <font-awesome-icon icon="file" class="text-xl text-gray-400" />
                </div>
              </div>
              <div class="flex-1 min-w-0">
                <p class="text-sm font-medium text-gray-900 dark:text-white truncate">{{ uploadedFile.name }}</p>
                <p class="text-xs text-gray-500 dark:text-gray-400">{{ formatFileSize(uploadedFile.size) }}</p>
              </div>
              <button 
                @click="removeFile"
                class="text-gray-400 hover:text-red-500 dark:text-gray-500 dark:hover:text-red-400 transition-colors"
              >
                <font-awesome-icon icon="times" class="text-sm" />
              </button>
            </div>
          </div>

          <!-- File Upload Prompt -->
          <div 
            v-else-if="config?.mainInput?.type === 'file'" 
            @click="$refs.fileInput?.click()"
            class="py-8 border-2 border-dashed border-gray-200 dark:border-gray-700 rounded-lg cursor-pointer hover:border-gray-300 dark:hover:border-gray-600 transition-colors text-center"
          >
            <font-awesome-icon icon="cloud-upload-alt" class="text-2xl text-gray-400 dark:text-gray-500 mb-2" />
            <p class="text-gray-600 dark:text-gray-400 text-sm">{{ $t(config.mainInput.placeholder) }}</p>
            <p class="text-xs text-gray-500 dark:text-gray-500 mt-1">
              {{ $t('input.supportedFormats') }}: {{ config.mainInput.acceptedTypes?.join(', ') }}
            </p>
          </div>
        </div>
      </div>

      <!-- Hidden File Input -->
      <input
        v-if="config?.allowFileUpload"
        ref="fileInput"
        type="file"
        :accept="config.mainInput?.acceptedTypes?.join(',')"
        @change="handleFileUpload"
        class="hidden"
      />

      <!-- Bottom Section with Options and Generate Button -->
      <div class="border-t border-gray-100 dark:border-gray-800 p-4">
        <div class="flex items-center justify-between">
          <!-- Left side: Options -->
          <div class="flex items-center space-x-4">
            <!-- Options -->
            <div v-if="config?.options?.length > 0" class="flex items-center space-x-3">
              <template v-for="option in config.options" :key="option.key">
                <!-- Select Option -->
                <div v-if="option.type === 'select'" class="relative">
                  <select 
                    :value="serviceStore.generationOptions[option.key]"
                    @change="serviceStore.updateOption(option.key, $event.target.value)"
                    @focus="isDropdownOpen = true"
                    @blur="isDropdownOpen = false"
                    class="appearance-none pl-3 pr-8 py-2 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300 rounded-full text-sm hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors cursor-pointer focus:outline-none focus:ring-2 focus:ring-blue-500 border-0"
                  >
                    <option v-for="choice in option.choices" :key="choice" :value="choice">
                      {{ $t(`input.options.${option.key}.${choice}`, choice) }}
                    </option>
                  </select>
                  <font-awesome-icon 
                    icon="chevron-down" 
                    class="absolute right-2 top-1/2 transform -translate-y-1/2 text-xs text-gray-500 pointer-events-none" 
                  />
                </div>

                <!-- Audio Toggle -->
                <button 
                  v-else-if="option.type === 'audio'"
                  @click="serviceStore.updateOption(option.key, !serviceStore.generationOptions[option.key])"
                  class="flex items-center space-x-2 px-4 py-2 bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 rounded-full transition-colors"
                  :class="serviceStore.generationOptions[option.key] ? 'ring-2 ring-blue-500' : ''"
                >
                  <font-awesome-icon icon="volume-high" class="text-sm text-gray-600 dark:text-gray-400" />
                  <span class="text-sm text-gray-700 dark:text-gray-300">{{ $t(`input.options.${option.key}`) }}</span>
                  <div 
                    class="w-4 h-4 rounded-full transition-colors"
                    :class="serviceStore.generationOptions[option.key] ? 'bg-blue-500' : 'bg-gray-300 dark:bg-gray-600'"
                  ></div>
                </button>
              </template>
            </div>

            <!-- Magic Wand Icon -->
            <button class="p-2 text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-300 transition-colors">
              <font-awesome-icon icon="wand-magic-sparkles" class="text-sm" />
            </button>
          </div>

          <!-- Right side: Generate Button -->
          <button 
            @click="handleGenerate"
            :disabled="!canGenerate || isGenerating"
            class="px-6 py-2 bg-green-500 hover:bg-green-600 disabled:bg-gray-300 dark:disabled:bg-gray-600 disabled:cursor-not-allowed text-white rounded-full font-medium transition-colors flex items-center space-x-2 text-sm"
          >
            <span v-if="!isGenerating">{{ $t('input.generate') }}</span>
            <span v-else class="flex items-center space-x-2">
              <span>{{ $t('input.generating') }}</span>
              <svg class="animate-spin h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
            </span>
            <span class="bg-green-600 dark:bg-green-400 text-white dark:text-green-900 px-2 py-1 rounded-full text-xs font-bold">
              {{ estimatedCost }}
            </span>
          </button>
        </div>

        <!-- Selected Service Badge and Abilities (moved to bottom) -->
        <div v-if="serviceStore.isServiceSelected" class="flex items-center justify-between mt-3 pt-3 border-t border-gray-100 dark:border-gray-800">
          <div class="flex items-center space-x-3">
            <!-- Service Badge -->
            <div class="flex items-center space-x-2 px-3 py-1 bg-blue-50 dark:bg-blue-900/20 rounded-full">
              <span class="text-xs font-medium text-blue-700 dark:text-blue-300">
                {{ selectedServiceName }}
              </span>
              <button 
                @click="serviceStore.clearSelection"
                class="text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300"
              >
                <font-awesome-icon icon="times" class="text-xs" />
              </button>
            </div>
            
            <!-- Service Abilities (discreet display) -->
            <div v-if="serviceAbilities.length > 0" class="flex items-center space-x-2">
              <span class="text-xs text-gray-500 dark:text-gray-400">{{ $t('services.abilities') }}:</span>
              <div class="flex items-center space-x-1">
                <span 
                  v-for="(ability, index) in serviceAbilities.slice(0, 3)" 
                  :key="ability.id"
                  class="text-xs text-gray-600 dark:text-gray-300"
                >
                  <span class="inline-flex items-center space-x-1">
                    <span class="text-gray-400">{{ ability.from_type }}</span>
                    <font-awesome-icon icon="arrow-right" class="text-xs text-gray-400" />
                    <span class="text-gray-400">{{ ability.to_type }}</span>
                  </span>
                  <span v-if="index < Math.min(serviceAbilities.length - 1, 2)" class="mx-1 text-gray-400">•</span>
                </span>
                <span v-if="serviceAbilities.length > 3" class="text-xs text-gray-500 dark:text-gray-400">
                  +{{ serviceAbilities.length - 3 }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'
import { useServiceStore } from '@/stores/service'
import { useAIServicesStore } from '@/stores/aiServices'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const serviceStore = useServiceStore()
const aiServicesStore = useAIServicesStore()

// Props et émissions
const props = defineProps({
  isGenerating: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['generate'])

// État local
const mainInputValue = ref('')
const secondaryInputValue = ref('')
const uploadedFile = ref(null)
const filePreview = ref(null)
const textareaRef = ref(null)

// Typewriter effect state
const dynamicPlaceholder = ref('')
const currentPlaceholderIndex = ref(0)
const currentCharIndex = ref(0)
const isTyping = ref(true)
const isPaused = ref(false)
const isDropdownOpen = ref(false) // Track if any dropdown is open
let typewriterInterval = null
let placeholderRotationTimeout = null

// Clés i18n pour les exemples de prompts par service
const servicePromptKeys = {
  text: {
    chatbot: [
      "placeholders.text.chatbot.example1",
      "placeholders.text.chatbot.example2",
      "placeholders.text.chatbot.example3"
    ],
    translator: [
      "placeholders.text.translator.example1",
      "placeholders.text.translator.example2",
      "placeholders.text.translator.example3"
    ],
    writer: [
      "placeholders.text.writer.example1",
      "placeholders.text.writer.example2",
      "placeholders.text.writer.example3"
    ]
  },
  image: {
    generator: [
      "placeholders.image.generator.example1",
      "placeholders.image.generator.example2",
      "placeholders.image.generator.example3"
    ],
    editor: [
      "placeholders.image.editor.example1",
      "placeholders.image.editor.example2",
      "placeholders.image.editor.example3"
    ],
    upscaler: [
      "placeholders.image.upscaler.example1",
      "placeholders.image.upscaler.example2",
      "placeholders.image.upscaler.example3"
    ]
  },
  audio: {
    generator: [
      "placeholders.audio.generator.example1",
      "placeholders.audio.generator.example2",
      "placeholders.audio.generator.example3"
    ],
    transcriber: [
      "placeholders.audio.transcriber.example1",
      "placeholders.audio.transcriber.example2",
      "placeholders.audio.transcriber.example3"
    ]
  },
  video: {
    generator: [
      "placeholders.video.generator.example1",
      "placeholders.video.generator.example2",
      "placeholders.video.generator.example3"
    ],
    editor: [
      "placeholders.video.editor.example1",
      "placeholders.video.editor.example2",
      "placeholders.video.editor.example3"
    ]
  }
}

// Config actuelle
const config = computed(() => serviceStore.currentConfig)

// Computed pour les prompts du service actuel
const currentServicePrompts = computed(() => {
  if (!serviceStore.selectedCategory || !serviceStore.selectedService) {
    return [
      t("placeholders.default.example1"),
      t("placeholders.default.example2"), 
      t("placeholders.default.example3")
    ]
  }
  
  const categoryPrompts = servicePromptKeys[serviceStore.selectedCategory]
  if (!categoryPrompts) {
    return [
      t("placeholders.fallback.example1"),
      t("placeholders.fallback.example2"),
      t("placeholders.fallback.example3")
    ]
  }
  
  const servicePromptsList = categoryPrompts[serviceStore.selectedService]
  if (!servicePromptsList) {
    return [
      t("placeholders.fallback.example1"),
      t("placeholders.fallback.example2"),
      t("placeholders.fallback.example3")
    ]
  }
  
  return servicePromptsList.map(key => t(key))
})

// Computed pour le service sélectionné
const selectedService = computed(() => {
  if (!serviceStore.selectedService) return null
  return aiServicesStore.services.find(s => s.id === serviceStore.selectedService)
})

const selectedServiceName = computed(() => {
  return selectedService.value?.name || ''
})

const serviceAbilities = computed(() => {
  if (!serviceStore.selectedService) return []
  return aiServicesStore.getServiceAbilities(serviceStore.selectedService)
})

// Computed
const canGenerate = computed(() => {
  if (!config.value) return false
  
  if (config.value.mainInput?.type === 'textarea') {
    return mainInputValue.value.trim().length > 0
  } else if (config.value.mainInput?.type === 'file') {
    return uploadedFile.value !== null
  }
  
  return false
})

const estimatedCost = computed(() => {
  // Si un service est sélectionné, utiliser son coût défini dans la base
  if (selectedService.value) {
    const baseCost = selectedService.value.default_cost_points || 1
    
    // Pour les services basés sur le texte, ajuster selon la longueur de l'input
    if (mainInputValue.value && config.value?.mainInput?.type === 'textarea') {
      const textLength = mainInputValue.value.trim().length
      const lengthFactor = Math.max(1, textLength / 1000) // Factor basé sur 1000 caractères
      return Math.max(1, Math.ceil(baseCost * lengthFactor))
    }
    
    // Pour les autres types de services, utiliser le coût de base
    return baseCost
  }

  // Minimum 1 point par requête
  return 1
})

// Methods
const handleFileUpload = (event) => {
  const file = event.target.files[0]
  if (file) {
    uploadedFile.value = file
    
    // Créer un aperçu pour les images
    if (isImage(file)) {
      const reader = new FileReader()
      reader.onload = (e) => {
        filePreview.value = e.target.result
      }
      reader.readAsDataURL(file)
    }
  }
}

const removeFile = () => {
  uploadedFile.value = null
  filePreview.value = null
  if (serviceStore.currentConfig?.mainInput?.type === 'file') {
    mainInputValue.value = ''
  }
}

const isImage = (file) => {
  return file && file.type.startsWith('image/')
}

const formatFileSize = (bytes) => {
  if (bytes < 1024) return bytes + ' B'
  if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB'
  return (bytes / (1024 * 1024)).toFixed(1) + ' MB'
}

const autoResize = () => {
  if (textareaRef.value) {
    textareaRef.value.style.height = 'auto'
    textareaRef.value.style.height = textareaRef.value.scrollHeight + 'px'
  }
}

// Typewriter effect functions
const startTypewriter = () => {
  if (isPaused.value || !currentServicePrompts.value.length || isDropdownOpen.value) return
  
  const currentPrompts = currentServicePrompts.value
  const currentPrompt = currentPrompts[currentPlaceholderIndex.value]
  
  if (isTyping.value) {
    // Typing phase
    if (currentCharIndex.value < currentPrompt.length) {
      dynamicPlaceholder.value = currentPrompt.substring(0, currentCharIndex.value + 1)
      currentCharIndex.value++
    } else {
      // Finished typing, wait then start erasing
      isTyping.value = false
      placeholderRotationTimeout = setTimeout(() => {
        if (!isPaused.value) {
          isTyping.value = false
        }
      }, 2000) // Wait 2 seconds before erasing
    }
  } else {
    // Erasing phase
    if (currentCharIndex.value > 0) {
      currentCharIndex.value--
      dynamicPlaceholder.value = currentPrompt.substring(0, currentCharIndex.value)
    } else {
      // Finished erasing, move to next prompt
      currentPlaceholderIndex.value = (currentPlaceholderIndex.value + 1) % currentPrompts.length
      isTyping.value = true
      // Small pause before starting to type the next prompt
      placeholderRotationTimeout = setTimeout(() => {
        if (!isPaused.value) {
          isTyping.value = true
        }
      }, 500)
    }
  }
}

const pauseTypewriter = () => {
  isPaused.value = true
  if (typewriterInterval) {
    clearInterval(typewriterInterval)
    typewriterInterval = null
  }
  if (placeholderRotationTimeout) {
    clearTimeout(placeholderRotationTimeout)
    placeholderRotationTimeout = null
  }
}

const resumeTypewriter = () => {
  if (mainInputValue.value.trim() === '' && !isDropdownOpen.value) {
    isPaused.value = false
    startTypewriterLoop()
  }
}

const startTypewriterLoop = () => {
  if (typewriterInterval) clearInterval(typewriterInterval)
  typewriterInterval = setInterval(startTypewriter, 100) // Adjust speed here
}

const resetTypewriter = () => {
  currentPlaceholderIndex.value = 0
  currentCharIndex.value = 0
  isTyping.value = true
  dynamicPlaceholder.value = ''
  
  if (typewriterInterval) {
    clearInterval(typewriterInterval)
    typewriterInterval = null
  }
  if (placeholderRotationTimeout) {
    clearTimeout(placeholderRotationTimeout)
    placeholderRotationTimeout = null
  }
  
  if (!isPaused.value) {
    startTypewriterLoop()
  }
}

const handleGenerate = () => {
  const data = {
    service: `${serviceStore.selectedCategory}/${serviceStore.selectedService}`,
    mainInput: mainInputValue.value || uploadedFile.value,
    secondaryInput: secondaryInputValue.value,
    options: serviceStore.generationOptions,
    estimatedCost: estimatedCost.value
  }
  
  emit('generate', data)
}

// Lifecycle
onMounted(() => {
  startTypewriterLoop()
})

onUnmounted(() => {
  pauseTypewriter()
})

// Réinitialiser les inputs quand le service change
watch(() => serviceStore.isServiceSelected, (isSelected) => {
  if (!isSelected) {
    mainInputValue.value = ''
    secondaryInputValue.value = ''
    uploadedFile.value = null
    filePreview.value = null
  }
})

// Reset typewriter when service changes
watch(() => [serviceStore.selectedCategory, serviceStore.selectedService], () => {
  resetTypewriter()
})

// Auto-resize du textarea quand le contenu change
watch(mainInputValue, () => {
  setTimeout(autoResize, 0)
  
  // Pause typewriter when user is typing
  if (mainInputValue.value.trim() !== '') {
    pauseTypewriter()
  } else if (!isPaused.value) {
    resumeTypewriter()
  }
})
</script>