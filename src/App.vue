<script setup>
import { onMounted } from 'vue'
import { RouterLink, RouterView } from 'vue-router'
import HelloWorld from './components/HelloWorld.vue'
import ThemeToggle from './components/ui/ThemeToggle.vue'
import LanguageSelector from './components/ui/LanguageSelector.vue'
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
    <header class="bg-white dark:bg-gray-800 shadow-sm border-b border-gray-200 dark:border-gray-700">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center py-4">
          <div class="flex items-center space-x-4">
            <img alt="Vue logo" class="logo w-12 h-12" src="@/assets/logo.svg" />
            <nav class="flex space-x-6">
              <RouterLink 
                to="/" 
                class="text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 transition-colors duration-200"
                :class="{ 'text-primary-600 dark:text-primary-400 font-semibold': $route.path === '/' }"
              >
                <font-awesome-icon icon="home" class="w-4 h-4 mr-2" />
                {{ $t('nav.home') }}
              </RouterLink>
              <RouterLink 
                to="/about" 
                class="text-gray-700 dark:text-gray-300 hover:text-primary-600 dark:hover:text-primary-400 transition-colors duration-200"
                :class="{ 'text-primary-600 dark:text-primary-400 font-semibold': $route.path === '/about' }"
              >
                <font-awesome-icon icon="info-circle" class="w-4 h-4 mr-2" />
                {{ $t('nav.about') }}
              </RouterLink>
            </nav>
          </div>
          
          <div class="flex items-center space-x-4">
            <HelloWorld :msg="$t('welcome.title')" />
          </div>
          
          <div class="flex items-center space-x-3">
            <LanguageSelector />
            <ThemeToggle />
          </div>
        </div>
      </div>
    </header>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <RouterView />
    </main>
  </div>
</template>

