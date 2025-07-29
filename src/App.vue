<script setup>
import { onMounted, computed, ref } from 'vue'
import { RouterLink, RouterView, useRoute } from 'vue-router'
import HelloWorld from './components/HelloWorld.vue'
import ThemeToggle from './components/ui/ThemeToggle.vue'
import LanguageSelector from './components/ui/LanguageSelector.vue'
import AppSideBar from './components/AppSideBar.vue'
import PaymentModal from './components/ui/PaymentModal.vue'
import { useThemeStore } from './stores/theme'
import { useLocaleStore } from './stores/locale'
import { useAuthStore } from './stores/auth'
import { useUserStore } from './stores/user'

const themeStore = useThemeStore()
const localeStore = useLocaleStore()
const authStore = useAuthStore()
const userStore = useUserStore()
const route = useRoute()

// State for payment modal
const showPaymentModal = ref(false)

// Computed pour déterminer si on est sur la page admin
const isAdminPage = computed(() => {
  return route.path.startsWith('/admin')
})

onMounted(() => {
  themeStore.initTheme()
  localeStore.initLocale()
})
</script>

<template>
  <div class="min-h-screen bg-white dark:bg-gray-900 transition-colors duration-200">
    <!-- Layout pour les pages normales (non-admin) -->
    <template v-if="!isAdminPage">
      <!-- Sidebar -->
      <AppSideBar />
      
      <!-- Main Content Area -->
      <div class="ml-64">
        <header class="bg-white dark:bg-gray-800 shadow-sm border-b border-gray-200 dark:border-gray-700">
          <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between items-center py-4">
              
              <!-- Search Bar -->
              <div class="flex-1 max-w-lg">
              </div>
              
              <div class="flex items-center space-x-4">
                <!-- Wallet Points -->
                <button 
                  @click="showPaymentModal = true"
                  class="flex items-center space-x-2 px-3 py-1 bg-yellow-100 dark:bg-yellow-900/20 rounded-full hover:bg-yellow-200 dark:hover:bg-yellow-900/30 transition-colors cursor-pointer"
                >
                  <span class="text-sm font-medium text-gray-900 dark:text-white">{{ userStore.formattedPoints }} {{ $t('payment.points') }}</span>
                  <font-awesome-icon icon="coins" class="text-yellow-500" />
                </button>
                
                <!-- Admin Link (if admin) -->
                <div v-if="authStore.userProfile?.is_admin" class="flex items-center">
                  <RouterLink 
                    to="/admin" 
                    class="flex items-center space-x-2 px-3 py-2 text-sm font-medium text-gray-700 dark:text-gray-200 hover:text-blue-600 dark:hover:text-blue-400 transition-colors"
                  >
                    <font-awesome-icon icon="cog" />
                    <span>Admin</span>
                  </RouterLink>
                </div>

                <!-- User Profile -->
                <div class="flex items-center space-x-2">
                  <div class="w-8 h-8 bg-gray-600 rounded-full flex items-center justify-center">
                    <font-awesome-icon icon="user" class="text-white text-sm" />
                  </div>
                </div>
                
                <!-- Theme and Language -->
                <div class="flex items-center space-x-2">
                  <LanguageSelector />
                  <ThemeToggle />
                </div>
              </div>
            </div>
          </div>
        </header>

        <main class="px-6 py-8">
          <RouterView />
        </main>
      </div>
    </template>

    <!-- Layout pour la page admin (sans AppSideBar) -->
    <template v-else>
      <RouterView />
    </template>

    <!-- Payment Modal -->
    <PaymentModal 
      :is-open="showPaymentModal" 
      @close="showPaymentModal = false" 
    />
  </div>
</template>

