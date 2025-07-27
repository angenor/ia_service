import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useServiceStore = defineStore('service', () => {
  // État
  const selectedCategory = ref(null)
  const selectedService = ref(null)
  const inputConfig = ref({})
  const generationOptions = ref({})

  // Configuration par défaut pour chaque type de service
  const serviceConfigs = {
    video: {
      textToVideo: {
        mainInput: {
          type: 'textarea',
          placeholder: 'input.video.textToVideoPlaceholder',
          rows: 3
        },
        options: [
          {
            key: 'aspectRatio',
            type: 'select',
            label: 'input.options.aspectRatio',
            default: '16:9',
            choices: ['16:9', '9:16', '1:1', '4:3', '3:4']
          },
          {
            key: 'duration',
            type: 'select',
            label: 'input.options.duration',
            default: '5s',
            choices: ['5s', '10s', '15s', '30s']
          },
          {
            key: 'style',
            type: 'select',
            label: 'input.options.style',
            default: 'realistic',
            choices: ['realistic', 'anime', 'cartoon', '3d', 'artistic']
          }
        ],
        allowFileUpload: false,
        acceptedFileTypes: []
      },
      imageToVideo: {
        mainInput: {
          type: 'file',
          placeholder: 'input.video.imageToVideoPlaceholder',
          acceptedTypes: ['image/jpeg', 'image/png', 'image/webp']
        },
        options: [
          {
            key: 'motion',
            type: 'select',
            label: 'input.options.motion',
            default: 'auto',
            choices: ['auto', 'zoom-in', 'zoom-out', 'pan-left', 'pan-right', 'rotate']
          },
          {
            key: 'duration',
            type: 'select',
            label: 'input.options.duration',
            default: '5s',
            choices: ['3s', '5s', '10s', '15s']
          }
        ],
        allowFileUpload: true,
        acceptedFileTypes: ['image/*']
      }
    },
    image: {
      textToImage: {
        mainInput: {
          type: 'textarea',
          placeholder: 'input.image.textToImagePlaceholder',
          rows: 2
        },
        options: [
          {
            key: 'size',
            type: 'select',
            label: 'input.options.size',
            default: '1024x1024',
            choices: ['512x512', '1024x1024', '1024x1792', '1792x1024']
          },
          {
            key: 'style',
            type: 'select',
            label: 'input.options.style',
            default: 'vivid',
            choices: ['vivid', 'natural', 'anime', 'photographic', 'digital-art', 'comic-book']
          },
          {
            key: 'quality',
            type: 'select',
            label: 'input.options.quality',
            default: 'standard',
            choices: ['standard', 'hd']
          }
        ],
        allowFileUpload: false,
        acceptedFileTypes: []
      },
      imageToImage: {
        mainInput: {
          type: 'file',
          placeholder: 'input.image.imageToImagePlaceholder',
          acceptedTypes: ['image/jpeg', 'image/png', 'image/webp']
        },
        secondaryInput: {
          type: 'textarea',
          placeholder: 'input.image.imageEditPrompt',
          rows: 2
        },
        options: [
          {
            key: 'strength',
            type: 'slider',
            label: 'input.options.strength',
            default: 0.7,
            min: 0,
            max: 1,
            step: 0.1
          },
          {
            key: 'style',
            type: 'select',
            label: 'input.options.style',
            default: 'auto',
            choices: ['auto', 'enhance', 'anime', 'photographic', 'digital-art']
          }
        ],
        allowFileUpload: true,
        acceptedFileTypes: ['image/*']
      }
    },
    music: {
      textToMusic: {
        mainInput: {
          type: 'textarea',
          placeholder: 'input.music.textToMusicPlaceholder',
          rows: 2
        },
        options: [
          {
            key: 'duration',
            type: 'select',
            label: 'input.options.duration',
            default: '30s',
            choices: ['15s', '30s', '60s', '120s']
          },
          {
            key: 'genre',
            type: 'select',
            label: 'input.options.genre',
            default: 'auto',
            choices: ['auto', 'pop', 'rock', 'jazz', 'classical', 'electronic', 'hip-hop', 'ambient']
          }
        ],
        allowFileUpload: false,
        acceptedFileTypes: []
      },
      generation: {
        mainInput: {
          type: 'textarea',
          placeholder: 'input.music.generationPlaceholder',
          rows: 2
        },
        options: [
          {
            key: 'duration',
            type: 'select',
            label: 'input.options.duration',
            default: '30s',
            choices: ['15s', '30s', '60s', '120s']
          },
          {
            key: 'style',
            type: 'select',
            label: 'input.options.style',
            default: 'instrumental',
            choices: ['instrumental', 'vocals', 'beats', 'ambient']
          }
        ],
        allowFileUpload: false,
        acceptedFileTypes: []
      }
    },
    llm: {
      chatgpt: {
        mainInput: {
          type: 'textarea',
          placeholder: 'input.llm.chatPlaceholder',
          rows: 3
        },
        options: [
          {
            key: 'model',
            type: 'select',
            label: 'input.options.model',
            default: 'gpt-4',
            choices: ['gpt-3.5-turbo', 'gpt-4', 'gpt-4-turbo']
          },
          {
            key: 'temperature',
            type: 'slider',
            label: 'input.options.temperature',
            default: 0.7,
            min: 0,
            max: 2,
            step: 0.1
          }
        ],
        allowFileUpload: true,
        acceptedFileTypes: ['text/*', 'application/pdf', 'image/*']
      },
      claude: {
        mainInput: {
          type: 'textarea',
          placeholder: 'input.llm.chatPlaceholder',
          rows: 3
        },
        options: [
          {
            key: 'model',
            type: 'select',
            label: 'input.options.model',
            default: 'claude-3-sonnet',
            choices: ['claude-3-haiku', 'claude-3-sonnet', 'claude-3-opus']
          },
          {
            key: 'temperature',
            type: 'slider',
            label: 'input.options.temperature',
            default: 0.7,
            min: 0,
            max: 1,
            step: 0.1
          }
        ],
        allowFileUpload: true,
        acceptedFileTypes: ['text/*', 'application/pdf', 'image/*']
      },
      gemini: {
        mainInput: {
          type: 'textarea',
          placeholder: 'input.llm.chatPlaceholder',
          rows: 3
        },
        options: [
          {
            key: 'model',
            type: 'select',
            label: 'input.options.model',
            default: 'gemini-pro',
            choices: ['gemini-pro', 'gemini-pro-vision']
          },
          {
            key: 'temperature',
            type: 'slider',
            label: 'input.options.temperature',
            default: 0.9,
            min: 0,
            max: 1,
            step: 0.1
          }
        ],
        allowFileUpload: true,
        acceptedFileTypes: ['text/*', 'application/pdf', 'image/*']
      },
      chat: {
        mainInput: {
          type: 'textarea',
          placeholder: 'input.llm.chatPlaceholder',
          rows: 3
        },
        options: [
          {
            key: 'model',
            type: 'select',
            label: 'input.options.model',
            default: 'gpt-4',
            choices: ['gpt-4', 'claude-3', 'gemini-pro', 'llama-3']
          },
          {
            key: 'temperature',
            type: 'slider',
            label: 'input.options.temperature',
            default: 0.7,
            min: 0,
            max: 2,
            step: 0.1
          }
        ],
        allowFileUpload: true,
        acceptedFileTypes: ['text/*', 'application/pdf', 'image/*']
      }
    },
    tools: {
      translation: {
        mainInput: {
          type: 'textarea',
          placeholder: 'input.tools.translationPlaceholder',
          rows: 3
        },
        options: [
          {
            key: 'targetLanguage',
            type: 'select',
            label: 'input.options.targetLanguage',
            default: 'en',
            choices: ['en', 'fr', 'es', 'de', 'it', 'pt', 'zh', 'ja', 'ko', 'ar']
          },
          {
            key: 'tone',
            type: 'select',
            label: 'input.options.tone',
            default: 'neutral',
            choices: ['neutral', 'formal', 'casual', 'technical']
          }
        ],
        allowFileUpload: true,
        acceptedFileTypes: ['text/*', 'application/pdf']
      },
      vision: {
        mainInput: {
          type: 'file',
          placeholder: 'input.tools.visionPlaceholder',
          acceptedTypes: ['image/jpeg', 'image/png', 'image/webp']
        },
        secondaryInput: {
          type: 'textarea',
          placeholder: 'input.tools.visionPrompt',
          rows: 2
        },
        options: [
          {
            key: 'analysisType',
            type: 'select',
            label: 'input.options.analysisType',
            default: 'general',
            choices: ['general', 'objects', 'text', 'faces', 'detailed']
          }
        ],
        allowFileUpload: true,
        acceptedFileTypes: ['image/*']
      }
    }
  }

  // Getters
  const currentConfig = computed(() => {
    if (!selectedCategory.value || !selectedService.value) {
      return null
    }
    
    const category = serviceConfigs[selectedCategory.value]
    if (!category) return null
    
    return category[selectedService.value] || null
  })

  const isServiceSelected = computed(() => {
    return selectedCategory.value !== null && selectedService.value !== null
  })

  // Actions
  function selectService(category, service) {
    selectedCategory.value = category
    selectedService.value = service
    
    // Réinitialiser les options avec les valeurs par défaut
    const config = serviceConfigs[category]?.[service]
    if (config?.options) {
      const defaults = {}
      config.options.forEach(option => {
        defaults[option.key] = option.default
      })
      generationOptions.value = defaults
    }
  }

  function updateOption(key, value) {
    generationOptions.value[key] = value
  }

  function clearSelection() {
    selectedCategory.value = null
    selectedService.value = null
    inputConfig.value = {}
    generationOptions.value = {}
  }

  return {
    selectedCategory,
    selectedService,
    inputConfig,
    generationOptions,
    currentConfig,
    isServiceSelected,
    selectService,
    updateOption,
    clearSelection
  }
})