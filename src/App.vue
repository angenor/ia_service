<script setup>
import { onMounted } from 'vue'
import { RouterLink, RouterView } from 'vue-router'
import HelloWorld from './components/HelloWorld.vue'
import ThemeToggle from './components/ui/ThemeToggle.vue'
import LanguageSelector from './components/ui/LanguageSelector.vue'
import AppSideBar from './components/AppSideBar.vue'
import { useThemeStore } from './stores/theme'
import { useLocaleStore } from './stores/locale'

const themeStore = useThemeStore()
const localeStore = useLocaleStore()

onMounted(() => {
  themeStore.initTheme()
  localeStore.initLocale()
})
</script>

<template>
  <div class="min-h-screen bg-white dark:bg-gray-900 transition-colors duration-200">
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
              <div class="flex items-center space-x-2 px-3 py-1 bg-yellow-100 dark:bg-yellow-900/20 rounded-full">
                <span class="text-sm font-medium text-gray-900 dark:text-white">1230 points</span>
                <font-awesome-icon icon="coins" class="text-yellow-500" />
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
  </div>
</template>

