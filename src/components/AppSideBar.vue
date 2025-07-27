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
          class="w-full bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-600 rounded-lg px-3 py-2 text-sm text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500"
        >
        <font-awesome-icon icon="search" class="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 text-sm" />
      </div>
    </div>

    <!-- Navigation -->
    <nav class="flex-1 overflow-y-auto px-2">

      <!-- Services par catégorie -->
      <div class="space-y-1">
        <!-- Vidéo -->
        <div class="mb-2">
          <button 
            @click="toggleCategory('video')"
            class="w-full text-left px-2 py-2 text-sm font-medium text-gray-900 dark:text-white hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center justify-between"
          >
            <div class="flex items-center space-x-2">
              <div class="w-5 h-5 bg-red-500 rounded flex items-center justify-center">
                <font-awesome-icon icon="file-video" class="text-xs text-white" />
              </div>
              <span>{{ $t('services.categories.video') }}</span>
            </div>
            <font-awesome-icon 
              :icon="expandedCategories.video ? 'chevron-up' : 'chevron-down'" 
              class="text-xs"
            />
          </button>
          <div v-show="expandedCategories.video" class="ml-6 space-y-1 mt-1">
            <button 
              @click="handleServiceSelect('video', 'textToVideo')"
              class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2"
              :class="{ 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300': isServiceSelected('video', 'textToVideo') }"
            >
              <div class="w-3 h-3 bg-red-400 rounded-full flex items-center justify-center">
                <font-awesome-icon icon="magic" class="text-xs text-white" style="font-size: 6px;" />
              </div>
              <span>{{ $t('services.video.textToVideo') }}</span>
            </button>
            <button 
              @click="handleServiceSelect('video', 'imageToVideo')"
              class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2"
              :class="{ 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300': isServiceSelected('video', 'imageToVideo') }"
            >
              <div class="w-3 h-3 bg-red-300 rounded-full flex items-center justify-center">
                <font-awesome-icon icon="arrow-right" class="text-xs text-white" style="font-size: 6px;" />
              </div>
              <span>{{ $t('services.video.imageToVideo') }}</span>
            </button>
          </div>
        </div>

        <!-- Images -->
        <div class="mb-2">
          <button 
            @click="toggleCategory('image')"
            class="w-full text-left px-2 py-2 text-sm font-medium text-gray-900 dark:text-white hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center justify-between"
          >
            <div class="flex items-center space-x-2">
              <div class="w-5 h-5 bg-purple-500 rounded flex items-center justify-center">
                <font-awesome-icon icon="palette" class="text-xs text-white" />
              </div>
              <span>{{ $t('services.categories.image') }}</span>
            </div>
            <font-awesome-icon 
              :icon="expandedCategories.image ? 'chevron-up' : 'chevron-down'" 
              class="text-xs"
            />
          </button>
          <div v-show="expandedCategories.image" class="ml-6 space-y-1 mt-1">
            <button 
              @click="handleServiceSelect('image', 'textToImage')"
              class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2"
              :class="{ 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300': isServiceSelected('image', 'textToImage') }"
            >
              <div class="w-3 h-3 bg-purple-400 rounded-full flex items-center justify-center">
                <font-awesome-icon icon="magic" class="text-xs text-white" style="font-size: 6px;" />
              </div>
              <span>{{ $t('services.image.textToImage') }}</span>
            </button>
            <button 
              @click="handleServiceSelect('image', 'imageToImage')"
              class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2"
              :class="{ 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300': isServiceSelected('image', 'imageToImage') }"
            >
              <div class="w-3 h-3 bg-purple-300 rounded-full flex items-center justify-center">
                <font-awesome-icon icon="arrow-right" class="text-xs text-white" style="font-size: 6px;" />
              </div>
              <span>{{ $t('services.image.imageToImage') }}</span>
            </button>
          </div>
        </div>

        <!-- Musique -->
        <div class="mb-2">
          <button 
            @click="toggleCategory('music')"
            class="w-full text-left px-2 py-2 text-sm font-medium text-gray-900 dark:text-white hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center justify-between"
          >
            <div class="flex items-center space-x-2">
              <div class="w-5 h-5 bg-green-500 rounded flex items-center justify-center">
                <font-awesome-icon icon="music" class="text-xs text-white" />
              </div>
              <span>{{ $t('services.categories.music') }}</span>
            </div>
            <font-awesome-icon 
              :icon="expandedCategories.music ? 'chevron-up' : 'chevron-down'" 
              class="text-xs"
            />
          </button>
          <div v-show="expandedCategories.music" class="ml-6 space-y-1 mt-1">
            <button 
              @click="handleServiceSelect('music', 'textToMusic')"
              class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2"
              :class="{ 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300': isServiceSelected('music', 'textToMusic') }"
            >
              <div class="w-3 h-3 bg-green-400 rounded-full flex items-center justify-center">
                <font-awesome-icon icon="magic" class="text-xs text-white" style="font-size: 6px;" />
              </div>
              <span>{{ $t('services.music.textToMusic') }}</span>
            </button>
            <button 
              @click="handleServiceSelect('music', 'generation')"
              class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2"
              :class="{ 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300': isServiceSelected('music', 'generation') }"
            >
              <div class="w-3 h-3 bg-green-300 rounded-full flex items-center justify-center">
                <font-awesome-icon icon="volume-up" class="text-xs text-white" style="font-size: 6px;" />
              </div>
              <span>{{ $t('services.music.generation') }}</span>
            </button>
          </div>
        </div>

        <!-- LLMs -->
        <div class="mb-2">
          <button 
            @click="toggleCategory('llm')"
            class="w-full text-left px-2 py-2 text-sm font-medium text-gray-900 dark:text-white hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center justify-between"
          >
            <div class="flex items-center space-x-2">
              <div class="w-5 h-5 bg-blue-500 rounded flex items-center justify-center">
                <font-awesome-icon icon="comments" class="text-xs text-white" />
              </div>
              <span>{{ $t('services.categories.llm') }}</span>
            </div>
            <font-awesome-icon 
              :icon="expandedCategories.llm ? 'chevron-up' : 'chevron-down'" 
              class="text-xs"
            />
          </button>
          <div v-show="expandedCategories.llm" class="ml-6 space-y-1 mt-1">
            <button 
              @click="handleServiceSelect('llm', 'chatgpt')"
              class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2"
              :class="{ 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300': isServiceSelected('llm', 'chatgpt') }"
            >
              <span class="w-3 h-3 bg-blue-500 rounded-sm"></span>
              <span>{{ $t('services.llm.chatgpt') }}</span>
            </button>
            <button 
              @click="handleServiceSelect('llm', 'claude')"
              class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2"
              :class="{ 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300': isServiceSelected('llm', 'claude') }"
            >
              <span class="w-3 h-3 bg-orange-500 rounded-sm"></span>
              <span>{{ $t('services.llm.claude') }}</span>
            </button>
            <button 
              @click="handleServiceSelect('llm', 'gemini')"
              class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2"
              :class="{ 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300': isServiceSelected('llm', 'gemini') }"
            >
              <span class="w-3 h-3 bg-purple-500 rounded-sm"></span>
              <span>{{ $t('services.llm.gemini') }}</span>
            </button>
          </div>
        </div>

        <!-- Outils -->
        <div class="mb-2">
          <button 
            @click="toggleCategory('tools')"
            class="w-full text-left px-2 py-2 text-sm font-medium text-gray-900 dark:text-white hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center justify-between"
          >
            <div class="flex items-center space-x-2">
              <div class="w-5 h-5 bg-orange-500 rounded flex items-center justify-center">
                <font-awesome-icon icon="wand-magic-sparkles" class="text-xs text-white" />
              </div>
              <span>{{ $t('services.categories.tools') }}</span>
            </div>
            <font-awesome-icon 
              :icon="expandedCategories.tools ? 'chevron-up' : 'chevron-down'" 
              class="text-xs"
            />
          </button>
          <div v-show="expandedCategories.tools" class="ml-6 space-y-1 mt-1">
            <button 
              @click="handleServiceSelect('tools', 'translation')"
              class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2"
              :class="{ 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300': isServiceSelected('tools', 'translation') }"
            >
              <div class="w-3 h-3 bg-orange-400 rounded-full flex items-center justify-center">
                <font-awesome-icon icon="language" class="text-xs text-white" style="font-size: 6px;" />
              </div>
              <span>{{ $t('services.tools.translation') }}</span>
            </button>
            <button 
              @click="handleServiceSelect('tools', 'vision')"
              class="w-full text-left px-2 py-1 text-xs text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-md flex items-center space-x-2"
              :class="{ 'bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300': isServiceSelected('tools', 'vision') }"
            >
              <div class="w-3 h-3 bg-orange-300 rounded-full flex items-center justify-center">
                <font-awesome-icon icon="eye" class="text-xs text-white" style="font-size: 6px;" />
              </div>
              <span>{{ $t('services.tools.vision') }}</span>
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
import { useRouter } from 'vue-router'
import LoginModal from '@/components/auth/LoginModal.vue'
import RegisterModal from '@/components/auth/RegisterModal.vue'
import ProfileModal from '@/components/profile/ProfileModal.vue'
import SettingsModal from '@/components/settings/SettingsModal.vue'

// Stores
const authStore = useAuthStore()
const serviceStore = useServiceStore()
const router = useRouter()

// État des catégories expandues
const expandedCategories = ref({
  video: false,
  image: false,
  music: false,
  llm: false,
  tools: false
})

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
const handleServiceSelect = (category, service) => {
  serviceStore.selectService(category, service)
}

const isServiceSelected = (category, service) => {
  return serviceStore.selectedCategory === category && serviceStore.selectedService === service
}

// Initialisation
onMounted(async () => {
  if (!authStore.user) {
    await authStore.initialize()
  }
})
</script>

<style scoped>
/* Styles personnalisés si nécessaire */
</style>