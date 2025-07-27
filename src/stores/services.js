import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useServicesStore = defineStore('services', () => {
  const categories = ref([])
  const subcategories = ref([])
  const services = ref([])
  const selectedCategory = ref(null)
  const selectedService = ref(null)

  // Categories with icons based on schema
  const defaultCategories = ref([
    {
      id: 'llm',
      slug: 'llm',
      name: 'Large Language Models',
      description: 'Conversational AI and text generation',
      icon: 'brain',
      sort_order: 1,
      is_active: true
    },
    {
      id: 'video-generation',
      slug: 'video-generation',
      name: 'Video Generation',
      description: 'AI-powered video creation',
      icon: 'video',
      sort_order: 2,
      is_active: true
    },
    {
      id: 'image-generation',
      slug: 'image-generation',
      name: 'Image Generation',
      description: 'AI image creation and editing',
      icon: 'image',
      sort_order: 3,
      is_active: true
    },
    {
      id: 'audio-services',
      slug: 'audio-services',
      name: 'Audio Services',
      description: 'Speech, music and audio processing',
      icon: 'music',
      sort_order: 4,
      is_active: true
    },
    {
      id: 'dev-assistance',
      slug: 'dev-assistance',
      name: 'Development Assistance',
      description: 'Code generation and development tools',
      icon: 'cog',
      sort_order: 5,
      is_active: true
    },
    {
      id: 'translation',
      slug: 'translation',
      name: 'Translation Services',
      description: 'Language translation and localization',
      icon: 'globe',
      sort_order: 6,
      is_active: true
    },
    {
      id: 'vision-analysis',
      slug: 'vision-analysis',
      name: 'Vision and Analysis',
      description: 'Image recognition and analysis',
      icon: 'eye',
      sort_order: 7,
      is_active: true
    },
    {
      id: 'search-rag',
      slug: 'search-rag',
      name: 'Search and RAG',
      description: 'Information retrieval and search',
      icon: 'search',
      sort_order: 8,
      is_active: true
    },
    {
      id: 'document-processing',
      slug: 'document-processing',
      name: 'Document Processing',
      description: 'Document analysis and processing',
      icon: 'file-pdf',
      sort_order: 10,
      is_active: true
    },
    {
      id: 'specialized',
      slug: 'specialized',
      name: 'Specialized Services',
      description: 'Specialized AI tools and services',
      icon: 'tools',
      sort_order: 11,
      is_active: true
    }
  ])

  // Subcategories based on schema
  const defaultSubcategories = ref([
    // Video generation subcategories
    {
      id: 'text-to-video',
      category_id: 'video-generation',
      slug: 'text-to-video',
      name: 'Text to Video',
      description: 'Generate videos from text descriptions',
      from_type: 'text',
      from_icon: 'file-text',
      to_type: 'video',
      to_icon: 'video',
      sort_order: 1,
      is_active: true
    },
    {
      id: 'image-to-video',
      category_id: 'video-generation',
      slug: 'image-to-video',
      name: 'Image to Video',
      description: 'Animate images into videos',
      from_type: 'image',
      from_icon: 'image',
      to_type: 'video',
      to_icon: 'video',
      sort_order: 2,
      is_active: true
    },
    // Audio services subcategories
    {
      id: 'text-to-speech',
      category_id: 'audio-services',
      slug: 'text-to-speech',
      name: 'Text to Speech',
      description: 'Convert text to natural speech',
      from_type: 'text',
      from_icon: 'file-text',
      to_type: 'audio',
      to_icon: 'volume-up',
      sort_order: 1,
      is_active: true
    },
    {
      id: 'speech-to-text',
      category_id: 'audio-services',
      slug: 'speech-to-text',
      name: 'Speech to Text',
      description: 'Transcribe audio to text',
      from_type: 'audio',
      from_icon: 'microphone',
      to_type: 'text',
      to_icon: 'file-text',
      sort_order: 2,
      is_active: true
    },
    {
      id: 'music-generation',
      category_id: 'audio-services',
      slug: 'music-generation',
      name: 'Music Generation',
      description: 'AI-powered music creation',
      from_type: 'text',
      from_icon: 'file-text',
      to_type: 'music',
      to_icon: 'music',
      sort_order: 3,
      is_active: true
    }
  ])

  // Mock AI services based on conception document
  const defaultServices = ref([
    // LLM Services
    {
      id: 'chatgpt-4',
      category_id: 'llm',
      slug: 'chatgpt-4',
      name: 'ChatGPT-4',
      description: 'Advanced conversational AI by OpenAI',
      provider: 'OpenAI',
      icon: 'brain',
      default_cost_points: 100,
      api_cost_usd: 0.03,
      is_active: true,
      is_new: false,
      features: ['Advanced reasoning', 'Code generation', 'Creative writing'],
      limitations: { max_tokens: 4096 }
    },
    {
      id: 'claude-4-sonnet',
      category_id: 'llm',
      slug: 'claude-4-sonnet',
      name: 'Claude 4 Sonnet',
      description: 'Anthropic\'s most capable AI assistant',
      provider: 'Anthropic',
      icon: 'brain',
      default_cost_points: 120,
      api_cost_usd: 0.025,
      is_active: true,
      is_new: true,
      features: ['Long context', 'Advanced analysis', 'Safe responses'],
      limitations: { max_tokens: 8192 }
    },
    {
      id: 'gemini-pro',
      category_id: 'llm',
      slug: 'gemini-pro',
      name: 'Gemini Pro',
      description: 'Google\'s multimodal AI model',
      provider: 'Google',
      icon: 'brain',
      default_cost_points: 80,
      api_cost_usd: 0.02,
      is_active: true,
      is_new: false,
      features: ['Multimodal', 'Fast responses', 'Code understanding'],
      limitations: { max_tokens: 2048 }
    },
    // Image Generation
    {
      id: 'dall-e-3',
      category_id: 'image-generation',
      slug: 'dall-e-3',
      name: 'DALL-E 3',
      description: 'Advanced AI image generation',
      provider: 'OpenAI',
      icon: 'image',
      default_cost_points: 200,
      api_cost_usd: 0.04,
      is_active: true,
      is_new: false,
      features: ['High quality', 'Creative prompts', 'Style consistency'],
      limitations: { max_size: '1024x1024' }
    },
    {
      id: 'flux-1',
      category_id: 'image-generation',
      slug: 'flux-1',
      name: 'Flux.1',
      description: 'High-quality image generation model',
      provider: 'fal.ai',
      icon: 'image',
      default_cost_points: 150,
      api_cost_usd: 0.035,
      is_active: true,
      is_new: true,
      features: ['Ultra realistic', 'Fast generation', 'Multiple styles'],
      limitations: { max_size: '1536x1536' }
    },
    // Video Generation - Text to Video
    {
      id: 'runway-gen3',
      category_id: 'video-generation',
      subcategory_id: 'text-to-video',
      slug: 'runway-gen3',
      name: 'RunwayML Gen-3',
      description: 'Professional video generation from text',
      provider: 'RunwayML',
      icon: 'video',
      default_cost_points: 500,
      api_cost_usd: 0.10,
      is_active: true,
      is_new: true,
      features: ['High resolution', 'Smooth motion', 'Multiple formats'],
      limitations: { max_duration: '10s' }
    },
    {
      id: 'pika-labs',
      category_id: 'video-generation',
      subcategory_id: 'text-to-video',
      slug: 'pika-labs',
      name: 'Pika Labs',
      description: 'Creative video generation AI',
      provider: 'Pika Labs',
      icon: 'video',
      default_cost_points: 400,
      api_cost_usd: 0.08,
      is_active: true,
      is_new: false,
      features: ['Creative effects', 'Style control', 'Fast processing'],
      limitations: { max_duration: '8s' }
    },
    // Audio Services - Text to Speech
    {
      id: 'elevenlabs-tts',
      category_id: 'audio-services',
      subcategory_id: 'text-to-speech',
      slug: 'elevenlabs-tts',
      name: 'ElevenLabs TTS',
      description: 'Ultra-realistic voice synthesis',
      provider: 'ElevenLabs',
      icon: 'volume-up',
      default_cost_points: 250,
      api_cost_usd: 0.05,
      is_active: true,
      is_new: false,
      features: ['Natural voices', 'Emotion control', 'Multiple languages'],
      limitations: { max_characters: 2500 }
    }
  ])

  // Computed getters
  const activeCategories = computed(() => 
    defaultCategories.value.filter(cat => cat.is_active).sort((a, b) => a.sort_order - b.sort_order)
  )

  const getSubcategoriesByCategory = computed(() => (categoryId) => 
    defaultSubcategories.value.filter(sub => sub.category_id === categoryId && sub.is_active)
  )

  const getServicesByCategory = computed(() => (categoryId) => 
    defaultServices.value.filter(service => service.category_id === categoryId && service.is_active)
  )

  const getServicesBySubcategory = computed(() => (subcategoryId) => 
    defaultServices.value.filter(service => service.subcategory_id === subcategoryId && service.is_active)
  )

  const newServices = computed(() => 
    defaultServices.value.filter(service => service.is_new && service.is_active)
  )

  const featuredServices = computed(() => 
    defaultServices.value.filter(service => service.is_active).slice(0, 6)
  )

  // Actions
  const selectCategory = (category) => {
    selectedCategory.value = category
  }

  const selectService = (service) => {
    selectedService.value = service
  }

  const getServicePrice = (serviceId, userCountry = 'US') => {
    const service = defaultServices.value.find(s => s.id === serviceId)
    if (!service) return 0
    
    // In a real app, this would check service_pricing_by_country table
    // For now, return default price
    return service.default_cost_points
  }

  const isServiceAvailable = (serviceId, userCountry = 'US') => {
    // In a real app, this would check service_availability table
    // For now, all services are available
    return true
  }

  // Initialize store
  const init = () => {
    categories.value = defaultCategories.value
    subcategories.value = defaultSubcategories.value
    services.value = defaultServices.value
  }

  return {
    // State
    categories,
    subcategories,
    services,
    selectedCategory,
    selectedService,
    
    // Getters
    activeCategories,
    getSubcategoriesByCategory,
    getServicesByCategory,
    getServicesBySubcategory,
    newServices,
    featuredServices,
    
    // Actions
    selectCategory,
    selectService,
    getServicePrice,
    isServiceAvailable,
    init
  }
})