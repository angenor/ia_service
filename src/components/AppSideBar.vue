<template>
  <aside class="fixed left-0 top-0 h-screen w-64 bg-white dark:bg-gray-900 border-r border-gray-200 dark:border-gray-700 flex flex-col">
    <!-- Header -->
    <div class="p-4 border-b border-gray-200 dark:border-gray-700">
      <div class="flex items-center space-x-2">
        <div class="w-8 h-8 bg-black dark:bg-white rounded-full flex items-center justify-center">
          <span class="text-white dark:text-black font-bold text-sm">IA</span>
        </div>
        <span class="font-semibold text-gray-900 dark:text-white">{{ $t('app.name') }}</span>
      </div>
    </div>
    <!-- Search -->
    <div class="px-4 pb-4 mt-2">
      <div class="relative">
        <input 
          type="text" 
          :placeholder="$t('sidebar.search')"
          v-model="searchQuery"
          class="w-full bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-600 rounded-lg px-3 py-2 text-sm text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
        <font-awesome-icon icon="search" class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 text-sm" />
      </div>
    </div>

    <!-- Navigation -->
    <nav class="flex-1 overflow-y-auto px-2">
      <!-- Services par catégorie -->
      <div class="space-y-1">
        <!-- Boucle sur les catégories -->
        <div v-for="category in filteredCategories" :key="category.id" class="mb-2">
          <button 
            @click="toggleCategory(category.slug)"
            class="w-full text-left px-2 py-2 text-sm font-medium text-gray-900 dark:text-white hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center justify-between"
          >
            <div class="flex items-center space-x-2">
              <div class="w-5 h-5 rounded flex items-center justify-center" :class="getCategoryColorClass(category.slug)">
                <font-awesome-icon :icon="getCategoryIcon(category.slug)" class="text-xs text-white" />
              </div>
              <span>{{ category.name }}</span>
            </div>
            <font-awesome-icon 
              :icon="expandedCategories[category.slug] ? 'chevron-up' : 'chevron-down'" 
              class="text-xs"
            />
          </button>
          <div v-show="expandedCategories[category.slug]" class="ml-6 space-y-1 mt-1">
            <!-- Services directement sous la catégorie -->
            <button 
              v-for="service in getFilteredServicesByCategory(category.id)"
              :key="service.id"
              @click="handleServiceSelect(service.id)"
              class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2"
              :class="{ 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300': isServiceSelected(service.id) }"
            >
              <span class="w-2 h-2 rounded-full" :class="getProviderColorClass(service.provider)"></span>
              <span class="flex-1">{{ service.name }}</span>
              <span v-if="service.is_new" class="text-xs px-1 py-0.5 bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200 rounded">New</span>
              <span class="text-xs text-gray-400 dark:text-gray-500">{{ service.default_cost_points }}pts</span>
            </button>
          </div>
        </div>
      </div>
    </nav>

    <!-- Bottom Section -->
    <div class="border-t border-gray-200 dark:border-gray-700 p-4 space-y-2">
      <!-- User Profile -->
      <div v-if="isAuthenticated" class="flex items-center space-x-3 p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md cursor-pointer">
        <div class="w-8 h-8 bg-blue-500 rounded-full flex items-center justify-center">
          <span class="text-white text-sm font-medium">
            {{ userProfile?.avatar_url ? '' : (userProfile?.full_name?.charAt(0) || user?.email?.charAt(0) || 'U') }}
          </span>
          <img 
            v-if="userProfile?.avatar_url" 
            :src="userProfile.avatar_url" 
            :alt="userProfile.full_name || user?.email"
            class="w-full h-full rounded-full object-cover"
          >
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-gray-900 dark:text-white truncate">
            {{ userProfile?.full_name || user?.email || $t('user.profile') }}
          </p>
          <p class="text-xs text-gray-500 dark:text-gray-400">
            {{ userProfile?.subscription_plan || $t('user.plan.free') }}
          </p>
        </div>
      </div>
      
      <!-- Non authentifié -->
      <div v-else class="flex items-center space-x-3 p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md cursor-pointer">
        <div class="w-8 h-8 bg-gray-500 rounded-full flex items-center justify-center">
          <font-awesome-icon icon="user" class="text-white text-sm" />
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-gray-900 dark:text-white truncate">{{ $t('auth.notConnected') }}</p>
          <p class="text-xs text-gray-500 dark:text-gray-400">{{ $t('auth.pleaseSignIn') }}</p>
        </div>
      </div>

      <!-- Menu Items -->
      <div class="space-y-1">
        <template v-if="isAuthenticated">
          <button 
            @click="showProfileModal = true"
            class="w-full text-left px-2 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2"
          >
            <font-awesome-icon icon="user" class="text-xs" />
            <span>{{ $t('sidebar.profile') }}</span>
          </button>
          <button 
            @click="showSettingsModal = true"
            class="w-full text-left px-2 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2"
          >
            <font-awesome-icon icon="cog" class="text-xs" />
            <span>{{ $t('sidebar.settings') }}</span>
          </button>
          <button 
            @click="handleSignOut"
            :disabled="loading"
            class="w-full text-left px-2 py-2 text-sm text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-md flex items-center space-x-2 disabled:opacity-50"
          >
            <font-awesome-icon icon="sign-out-alt" class="text-xs" />
            <span>{{ loading ? $t('auth.signingOut') : $t('auth.signOut') }}</span>
          </button>
        </template>
        <template v-else>
          <button 
            @click="showLoginModal = true"
            class="w-full text-left px-2 py-2 text-sm text-blue-600 dark:text-blue-400 hover:bg-blue-50 dark:hover:bg-blue-900/20 rounded-md flex items-center space-x-2"
          >
            <font-awesome-icon icon="sign-in-alt" class="text-xs" />
            <span>{{ $t('auth.signIn') }}</span>
          </button>
          <button 
            @click="showRegisterModal = true"
            class="w-full text-left px-2 py-2 text-sm text-green-600 dark:text-green-400 hover:bg-green-50 dark:hover:bg-green-900/20 rounded-md flex items-center space-x-2"
          >
            <font-awesome-icon icon="user-plus" class="text-xs" />
            <span>{{ $t('auth.signUp') }}</span>
          </button>
        </template>
        <button 
          @click="router.push('/about')"
          class="w-full text-left px-2 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2"
        >
          <font-awesome-icon icon="info-circle" class="text-xs" />
          <span>{{ $t('sidebar.about') }}</span>
        </button>
        <button 
          @click="router.push('/contact')"
          class="w-full text-left px-2 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2"
        >
          <font-awesome-icon icon="envelope" class="text-xs" />
          <span>{{ $t('sidebar.contact') }}</span>
        </button>
      </div>
    </div>
  </aside>
  
  <!-- Modals -->
  <LoginModal 
    v-model="showLoginModal" 
    @show-register="showLoginModal = false; showRegisterModal = true"
  />
  <RegisterModal 
    v-model="showRegisterModal" 
    @show-login="showRegisterModal = false; showLoginModal = true"
  />
  <ProfileModal 
    v-model="showProfileModal"
  />
  <SettingsModal 
    v-model="showSettingsModal"
  />
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useServiceStore } from '@/stores/service'
import { useAIServicesStore } from '@/stores/aiServices'
import { useRouter } from 'vue-router'
import LoginModal from '@/components/auth/LoginModal.vue'
import RegisterModal from '@/components/auth/RegisterModal.vue'
import ProfileModal from '@/components/profile/ProfileModal.vue'
import SettingsModal from '@/components/settings/SettingsModal.vue'

// Stores
const authStore = useAuthStore()
const serviceStore = useServiceStore()
const aiServicesStore = useAIServicesStore()
const router = useRouter()

// État des catégories expandues
const expandedCategories = ref({
  llm: false,
  'video-generation': false,
  'image-generation': false,
  'audio-services': false,
  'dev-assistance': false,
  translation: false,
  'vision-analysis': false,
  'search-rag': false,
  '3d-avatars': false,
  'document-processing': false,
  specialized: false
})

// État de recherche
const searchQuery = ref('')

// État des modals
const showLoginModal = ref(false)
const showRegisterModal = ref(false)
const showProfileModal = ref(false)
const showSettingsModal = ref(false)

// Computed properties pour l'utilisateur
const user = computed(() => authStore.user)
const userProfile = computed(() => authStore.userProfile)
const isAuthenticated = computed(() => authStore.isAuthenticated)
const loading = computed(() => authStore.loading)

// Fonction pour toggle une catégorie
const toggleCategory = (category) => {
  expandedCategories.value[category] = !expandedCategories.value[category]
}

// Fonction de déconnexion
const handleSignOut = async () => {
  try {
    await authStore.signOut()
    router.push('/login')
  } catch (error) {
    console.error('Erreur lors de la déconnexion:', error)
  }
}

// Fonctions pour la sélection de service
const handleServiceSelect = (serviceId) => {
  serviceStore.selectService(serviceId)
}

const isServiceSelected = (serviceId) => {
  return serviceStore.selectedService === serviceId
}

// Computed properties pour les données
const categories = computed(() => aiServicesStore.activeCategories)
const servicesByCategory = computed(() => aiServicesStore.servicesByCategory)

// Filtrer les catégories selon la recherche
const filteredCategories = computed(() => {
  if (!searchQuery.value) return categories.value
  
  const query = searchQuery.value.toLowerCase()
  return categories.value.filter(category => {
    // Vérifier si le nom de la catégorie correspond
    if (category.name.toLowerCase().includes(query)) return true
    
    // Vérifier si un des services de cette catégorie correspond
    const categoryServices = servicesByCategory.value[category.id] || []
    return categoryServices.some(service => 
      service.name.toLowerCase().includes(query) ||
      service.provider?.toLowerCase().includes(query)
    )
  })
})

// Obtenir les services filtrés d'une catégorie
const getFilteredServicesByCategory = (categoryId) => {
  const categoryServices = servicesByCategory.value[categoryId] || []
  
  if (!searchQuery.value) return categoryServices
  
  const query = searchQuery.value.toLowerCase()
  return categoryServices.filter(service => 
    service.name.toLowerCase().includes(query) ||
    service.provider?.toLowerCase().includes(query)
  )
}

// Fonction pour obtenir l'icône d'une catégorie
const getCategoryIcon = (categorySlug) => {
  const icons = {
    'llm': 'brain',
    'video-generation': 'video',
    'image-generation': 'image',
    'audio-services': 'volume-up',
    'dev-assistance': 'code',
    'translation': 'language',
    'vision-analysis': 'eye',
    'search-rag': 'search',
    '3d-avatars': 'cube',
    'document-processing': 'file-alt',
    'specialized': 'cog'
  }
  return icons[categorySlug] || 'folder'
}

// Fonction pour obtenir la classe de couleur d'une catégorie
const getCategoryColorClass = (categorySlug) => {
  const colors = {
    'llm': 'bg-blue-500',
    'video-generation': 'bg-red-500',
    'image-generation': 'bg-purple-500',
    'audio-services': 'bg-green-500',
    'dev-assistance': 'bg-indigo-500',
    'translation': 'bg-yellow-500',
    'vision-analysis': 'bg-pink-500',
    'search-rag': 'bg-orange-500',
    '3d-avatars': 'bg-teal-500',
    'document-processing': 'bg-gray-500',
    'specialized': 'bg-cyan-500'
  }
  return colors[categorySlug] || 'bg-gray-500'
}

// Fonction pour obtenir la classe de couleur d'un provider
const getProviderColorClass = (provider) => {
  const colors = {
    'anthropic': 'bg-orange-500',
    'openai': 'bg-green-500',
    'google': 'bg-blue-500',
    'meta': 'bg-blue-600',
    'meta-llama': 'bg-blue-600',
    'mistral': 'bg-gray-600',
    'fal': 'bg-purple-500',
    'replicate': 'bg-red-500',
    'huggingface': 'bg-yellow-500',
    'deepseek': 'bg-indigo-500',
    'qwen': 'bg-teal-500',
    'xai': 'bg-purple-600'
  }
  return colors[provider?.toLowerCase()] || 'bg-gray-500'
}

// Initialisation
onMounted(async () => {
  if (!authStore.user) {
    await authStore.initialize()
  }
  // Charger toutes les données nécessaires
  await aiServicesStore.fetchAllData()
})
</script>

<style scoped>
/* Styles personnalisés si nécessaire */
</style>